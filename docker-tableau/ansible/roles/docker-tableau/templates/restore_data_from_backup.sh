#!/bin/bash
set -eu
set -o pipefail # To handle errors during pipe commands
cd  {{ docker_tableau_deploy_dir }}

BACKUP_TO_RESTORE=""
RESTORE_FROM_LATEST_BACKUP=""

# Parsing command line arguments
while [[ "$#" > 0 ]]; do case $1 in
  --file)   BACKUP_TO_RESTORE=$2; shift 2;;
  --latest) RESTORE_FROM_LATEST_BACKUP=1; shift 1;;
  *) "Unknown parameter passed: $1"; exit 1;;
esac; done

if [[ -z "$BACKUP_TO_RESTORE" && -z "$RESTORE_FROM_LATEST_BACKUP" ]]; then
    echo "You need to specify --filename with name of .tsbak file to restore from, or --latest to restore from latest backup";
    exit 1;
fi

if [[ -n "$RESTORE_FROM_LATEST_BACKUP" ]]; then
  BACKUP_TO_RESTORE=$(ls -1r {{ tableau_backups_dir }} | grep tsm_backup | tail -n1);
fi

# If BACKUP_TO_RESTORE is empty or file not readable - say backup does not exist
if [[ -z "$BACKUP_TO_RESTORE" || ! -r "{{ tableau_backups_dir }}/$BACKUP_TO_RESTORE" ]]; then
    echo "No such backup found in {{ tableau_backups_dir }} dir. Exiting";
    exit 1;
fi

docker-compose exec -T tableau-server tsm maintenance restore --file $BACKUP_TO_RESTORE
docker-compose exec -T tableau-server tsm start
