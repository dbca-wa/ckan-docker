#!/usr/bin/env sh
# The devcontainer CLI inspects the Dockerfile's base image before building, pulling it
# with no platform flag — which fails on Apple Silicon, as ckan/ckan-dev is amd64-only.
# Pre-pull it here (devcontainer.json initializeCommand); no-op once it is cached.
set -e
cd "$(dirname "$0")/.."
image=$(awk '$1 == "FROM" { print $NF; exit }' ckan/Dockerfile.dev)
docker image inspect "$image" >/dev/null 2>&1 || docker pull --platform linux/amd64 "$image"
