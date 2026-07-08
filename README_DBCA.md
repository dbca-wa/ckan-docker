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

1. Install and run [Pygmy](https://github.com/pygmystack/pygmy) — provides host-side DNS
   resolution for `*.docker.amazee.io` domains.
2. In `.env`, switch `CKAN_SITE_URL` to the commented-out amazee alternative
   (`http://$LAGOON_LOCALDEV_URL`, no port — Pygmy fronts it on the default port 80),
   then `ahoy up` to recreate.
3. `docker-compose.dev.yml`'s `extra_hosts` entry (`${LAGOON_LOCALDEV_URL}:host-gateway`)
   is already in place on both `ckan-dev` and `ckan-dev-worker` — no host `/etc/hosts`
   edit needed inside the containers; Pygmy handles resolution on the host side for your
   browser.
4. Switch `CKAN_SITE_URL` back to `localhost` when done — it's a Salsa-internal
   dependency, not something the client or other developers need for normal work.

## How to implement the security patch for the CKAN
- Run the GH action to generate the image, if not already done. see this https://salsadigital.atlassian.net/wiki/spaces/CKAN/pages/3499819055/CKAN+patching#Upgrade-Salsa-CKAN-Base-Images.
- Update the image version with latest in below files.
   - .env.dbca
   - .env.example
   - README.md
   - ckan/Dockerfile
   - ckan/Dockerfile.dev
- Run the build and make sure all patches are applied cleanly ckan/patches
