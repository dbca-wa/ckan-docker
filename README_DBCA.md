# Docker Compose setup for DBCA CKAN

## Install Dependencies
- docker
- git
- ahoy (https://github.com/ahoy-cli/ahoy)

## Configure extensions that will be worked on
 - Add any extensions you will be modifying in the file `src/dbca_install_extensions.sh`

## Init and build local dev environment
- ahoy init
  - This will clone the extensions from `dbca_install_extensions.sh` to the `src` folder which will be a mounted folder to the ckan docker containers
  - Copy the `.env.dbca` to `.env` which is the env file uses for the CKAN docker containers
    - Update the `.env` file to. The extension https://github.com/okfn/ckanext-envvars reads this file on CKAN startup and require to be in a certain format. Please read the readme file https://github.com/okfn/ckanext-envvars#ckanext-envvars
      - Enable plugins via `CKAN__PLUGINS`
      - Add/Update CKAN core configuration values
      - Add/Update CKAN extensions configuration values
      - Any updates to this file will recreate the container service to use the updates values when `ahoy up` is used
- ahoy build (Build the projects docker images)
- ahoy up (Starts the projects container services)
  - The first time the CKAN Dev containers are created the mapped volume will look in the `src:/srv/app/src_extensions` folder to install any extensions cloned from the `ahoy init` step and will pip install the extension and any any requirements file if they exists
- To see the list of available commands with short descriptions run ahoy
```
ahoy
NAME:
   ahoy - Creates a configurable cli app for running commands.
USAGE:
   ahoy [global options] command [command options] [arguments...]

COMMANDS:
   attach              Attach to a running container
   build               Build project.
   cli                 Start a shell inside container.
   db-dump             Dump data out into a file. `ahoy db-dump local.dump`
   db-import           Pipe in a postgres dump file.  `ahoy db-import local.dump`
   down                Delete project (CAUTION).
   generate-extension  Generates a new CKAN extension into the src directory
   info                Print information about this project.
   init                Initialise the codebase on first-time setup (ahoy init)
   logs                Show Docker logs.
   open                Open the site in your default browser
   ps                  List running Docker containers.
   recreate            Recreate a local container | ahoy recreate ckan
   restart             Restart Docker containers.
   run                 Run command inside container.
   stop                Stop Docker containers.
   up                  Build project.

GLOBAL OPTIONS:
   --verbose, -v               Output extra details like the commands to be run. [$AHOY_VERBOSE]
   --file value, -f value      Use a specific ahoy file.
   --help, -h                  show help
   --version                   print the version
   --generate-bash-completion

VERSION:
   2.0.2-homebrew

[fatal] Missing flag or argument.
```

## Testing SAML login locally (Pygmy, optional)

By default local dev uses `CKAN_SITE_URL=http://localhost:$CKAN_PORT_HOST` (`5000` unless
you've overridden `CKAN_PORT_HOST` locally, e.g. to avoid a port conflict) — no extra
tooling required, matches upstream `ckan-docker` convention.

Xloader's worker-to-CKAN calls (resource fetch + job-status callback) already work
without any of this, via `CKANEXT__XLOADER__SITE_URL=http://ckan-dev:5000` in `.env` /
`.env.dbca`, which points those calls directly at the `ckan-dev` compose service instead
of round-tripping through `CKAN_SITE_URL`.

The one thing `localhost` can't do is SAML login testing, since the IdP's registered
callback URL won't match `localhost`. To test SAML locally:

1. Install and run [Pygmy](https://github.com/pygmystack/pygmy). Pygmy runs its own
   `amazeeio-haproxy` + `amazeeio-dnsmasq` containers, which route `*.docker.amazee.io`
   traffic (port 80, no port needed) to whichever container asks for it — this is
   different from plain DNS/`extra_hosts`, and needs a container to actually register
   with Pygmy's proxy (see step 2).
2. Layer `docker-compose.pygmy.yml` on top of the normal dev stack to register
   `ckan-dev` with Pygmy's proxy:
   ```
   docker compose -f docker-compose.dev.yml -f docker-compose.pygmy.yml up -d
   ```
   This joins `ckan-dev` to Pygmy's `amazeeio-network` and sets `LAGOON_ROUTE` so its
   haproxy picks it up. Requires the `amazeeio-network` Docker network to already exist
   (i.e. Pygmy running) — that's why this isn't in `docker-compose.dev.yml` itself;
   referencing a non-existent external network would break `docker compose up` for
   everyone without Pygmy installed.
3. In `.env`, switch `CKAN_SITE_URL` to the commented-out amazee alternative
   (`http://$LAGOON_LOCALDEV_URL`, no port) if you need CKAN's own site URL to match
   what you're browsing (e.g. for SAML, where the IdP checks the callback domain).
4. When done, bring the stack back up with just `docker-compose.dev.yml` (no
   `-f docker-compose.pygmy.yml`) to leave `ckan-dev` off Pygmy's network again, and
   switch `CKAN_SITE_URL` back to `localhost` — it's a Salsa-internal dependency, not
   something the client or other developers need for normal work.

**Gotcha (fixed, but worth knowing):** `ckan-dev-worker` shares the same `.env` file as
`ckan-dev` via `env_file`. Pygmy's `docker-gen` treats *any* container carrying
`LAGOON_LOCALDEV_URL`/`LAGOON_LOCALDEV_HTTP_PORT` as a routing candidate for that
hostname — regardless of network membership or whether `LAGOON_ROUTE` is actually set —
so without an explicit override, `ckan-dev-worker` also gets registered under the same
route as `ckan-dev`, and Pygmy's haproxy config fails to load at all (duplicate backend
name) — breaking routing for *every* project on the machine, not just this one.
`docker-compose.dev.yml` blanks those two vars for `ckan-dev-worker` specifically to
prevent this; leave that in place.

## How to implement the security patch for the CKAN
- Run the GH action to generate the image, if not already done. see this https://salsadigital.atlassian.net/wiki/spaces/CKAN/pages/3499819055/CKAN+patching#Upgrade-Salsa-CKAN-Base-Images.
- Update the image version with latest in below files.
   - .env.dbca
   - .env.example
   - README.md
   - ckan/Dockerfile
   - ckan/Dockerfile.dev
- Run the build and make sure all patches are applied cleanly ckan/patches
