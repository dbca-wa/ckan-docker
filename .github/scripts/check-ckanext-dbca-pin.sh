#!/usr/bin/env bash
#
# Release guard: ckan-docker and ckanext-dbca are built and deployed together, so a
# master build must ship a released extension, not whatever happens to be on a branch.
# Run on PRs into master (see release-checks.yml) and locally from the repo root.
#
# Checks:
#   1. dbca_requirements.sh pins an immutable ref (tag or SHA), not a branch.
#   2. That ref exists and is reachable from ckanext-dbca main — i.e. it was released.
#   3. ckanext-dbca develop is not ahead of main — i.e. no unreleased extension work.
set -euo pipefail

REPO_URL="https://github.com/dbca-wa/ckanext-dbca.git"
REQ_FILE="ckan/setup/dbca_requirements.sh"

fail() { printf '\n\033[31mFAIL\033[0m  %s\n' "$1" >&2; failed=1; }
pass() { printf '\033[32mok\033[0m    %s\n' "$1"; }
failed=0

# Pull the ref out of the install line, then unwrap ${CKANEXT_DBCA_REF:-<ref>}.
pin=$(sed -n 's|.*ckanext-dbca\.git@\([^#]*\)#egg=ckanext-dbca.*|\1|p' "$REQ_FILE")
[ -n "$pin" ] || { echo "Could not find the ckanext-dbca install line in $REQ_FILE" >&2; exit 1; }
pin=${pin#'${CKANEXT_DBCA_REF:-'}
pin=${pin%\}}
echo "ckanext-dbca pinned to: $pin"

# 1. Immutable ref, not a branch.
if [ -n "$(git ls-remote --heads "$REPO_URL" "$pin")" ]; then
  fail "'$pin' is a branch. Pin a tag or commit SHA so the master image is reproducible
      (a branch pin means a rebuild — e.g. a CKAN security patch — silently picks up
      whatever landed on that branch since the release)."
else
  pass "'$pin' is not a branch"
fi

work=$(mktemp -d); trap 'rm -rf "$work"' EXIT
git clone --quiet --filter=blob:none --no-checkout "$REPO_URL" "$work/ext"

# 2. Ref exists and was released to main.
# A fresh clone only creates a local branch for the default branch, so try the
# remote-tracking ref too before concluding the ref doesn't exist.
if ! sha=$(git -C "$work/ext" rev-parse --quiet --verify "$pin^{commit}" 2>/dev/null) &&
   ! sha=$(git -C "$work/ext" rev-parse --quiet --verify "origin/$pin^{commit}" 2>/dev/null); then
  fail "'$pin' does not exist in ckanext-dbca."
elif ! git -C "$work/ext" merge-base --is-ancestor "$sha" origin/main; then
  fail "'$pin' ($(git -C "$work/ext" rev-parse --short "$sha")) is not reachable from
      ckanext-dbca main — it has not been released. Merge the extension release PR
      to main and tag it, then pin that tag."
else
  pass "'$pin' is released on main"
fi

# 3. No unreleased extension work.
git -C "$work/ext" fetch --quiet origin develop
ahead=$(git -C "$work/ext" rev-list --count origin/main..origin/develop)
if [ "$ahead" -gt 0 ]; then
  fail "ckanext-dbca develop is $ahead commit(s) ahead of main. There is unreleased
      extension work — check for an open develop -> main PR and release it first:"
  git -C "$work/ext" log --oneline --no-decorate origin/main..origin/develop |
    head -5 | sed 's/^/        /' >&2
else
  pass "ckanext-dbca develop is level with main"
fi

echo
[ "$failed" -eq 0 ] && echo "All release checks passed." || echo "Release checks failed."
exit "$failed"
