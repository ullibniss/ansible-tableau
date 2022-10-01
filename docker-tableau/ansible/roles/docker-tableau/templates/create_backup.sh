#!/bin/bash
set -eu
set -o pipefail # To handle errors during pipe commands
export AWS_ACCESS_KEY_ID={{ docker_tableau_s3_backups.access_key_id }}
export AWS_SECRET_ACCESS_KEY={{ docker_tableau_s3_backups.secret_access_key }}
export AWS_DEFAULT_REGION={{ docker_tableau_s3_backups.region }}

cd {{ docker_tableau_deploy_dir }}

CURRENT_DATE=$(date +\%Y.\%m.\%d-\%H:\%M:\%S)

echo "Creating settings backup into file backups/settings/settings-$CURRENT_DATE.json"
docker-compose exec -T tableau-server tsm settings export -f {{ docker_tableau_internal_backups_dir }}/settings/settings-$CURRENT_DATE.json

{% if tableau_autoupload_backups_to_s3 %}
echo "Upload settings backup into S3 bucket"
aws --endpoint-url {{ docker_tableau_s3_backups.endpoint_url }} s3 cp {{ docker_tableau_backups_dir }}/settings/settings-$CURRENT_DATE.json {{ docker_tableau_s3_backups_url }}/settings/settings-$CURRENT_DATE.json
{% endif %}

echo "Creating data backup into file backups/tsm_backup-$CURRENT_DATE.json"
docker-compose exec -T tableau-server tsm maintenance backup -f tsm_backup-$CURRENT_DATE.tsbak

{% if tableau_autoupload_backups_to_s3 %}
echo "Upload data backup into S3 bucket"
aws --endpoint-url {{ docker_tableau_s3_backups.endpoint_url }} s3 cp {{ docker_tableau_backups_dir }}/tsm_backup-$CURRENT_DATE.tsbak {{ docker_tableau_s3_backups_url }}/tsm_backup-$CURRENT_DATE.tsbak
{% endif %}


{% if docker_tableau_autoremove_old_backups %}
echo "Remove old backups (keeping only last {{ tableau_max_backups_num }})"
DATA_FILENAMES_TO_REMOVE=$(ls -1r {{ tableau_backups_dir }} | grep tsm_backup | tail +{{ tableau_max_backups_num + 1 }})
SETTINGS_FILENAMES_TO_REMOVE=$(ls -1r {{ tableau_backups_dir }}/settings | tail +{{ tableau_max_backups_num + 1 }})

echo "Prepare to remove old settings backups"
if [ -z "$SETTINGS_FILENAMES_TO_REMOVE" ]; then
    echo "No settings pending for removal, skipping";
else
    echo "Settings for removal: $SETTINGS_FILENAMES_TO_REMOVE";
    cd {{ docker_tableau_backups_dir }}/settings
    rm -f $SETTINGS_FILENAMES_TO_REMOVE
    echo "Removed successfully"
fi

echo "Prepare to remove old data backups"
if [ -z "$DATA_FILENAMES_TO_REMOVE" ]; then
    echo "No data backups pending for removal, skipping";
else
    echo "Data backups for removal: $DATA_FILENAMES_TO_REMOVE";
    cd {{ docker_tableau_backups_dir }}
    rm -f $DATA_FILENAMES_TO_REMOVE
    echo "Removed successfully"
fi
{% endif %}


echo "Successfully finished!"
