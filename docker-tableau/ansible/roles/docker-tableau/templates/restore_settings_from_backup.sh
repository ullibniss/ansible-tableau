#!/bin/bash
set -eu
set -o pipefail # To handle errors during pipe commands
cd  {{ docker_tableau_deploy_dir }}

SETTINGS_FILE_TO_APPLY=""
APPLY_LATEST_SETTINGS=""

# Parsing command line arguments
while [[ "$#" > 0 ]]; do case $1 in
  --file)   SETTINGS_FILE_TO_APPLY=$2; shift 2;;
  --latest) APPLY_LATEST_SETTINGS=1; shift 1;;
  *) "Unknown parameter passed: $1"; exit 1;;
esac; done

if [[ -z "$SETTINGS_FILE_TO_APPLY" && -z "$APPLY_LATEST_SETTINGS" ]]; then
    echo "You need to specify --filename with name of .json settings file to apply, or --latest to apply latest settings";
    exit 1;
fi

if [[ -n "$APPLY_LATEST_SETTINGS" ]]; then
  SETTINGS_FILE_TO_APPLY=$(ls -1r {{ tableau_backups_dir }}/settings | tail -n1)
fi

# If BACKUP_TO_RESTORE is empty or file not readable - say backup does not exist
if [[ -z "$SETTINGS_FILE_TO_APPLY" || ! -r "{{ tableau_backups_dir }}/settings/$SETTINGS_FILE_TO_APPLY" ]]; then
    echo "No such settings file found in ./backups/settings/ dir. Exiting";
    exit 1;
fi

docker-compose exec -T tableau-server tsm settings import -f {{ docker_tableau_internal_backups_dir }}/settings/$SETTINGS_FILE_TO_APPLY
docker-compose exec -T tableau-server tsm pending-changes apply --ignore-warnings
