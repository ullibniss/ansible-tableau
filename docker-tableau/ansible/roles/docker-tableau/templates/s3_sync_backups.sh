#!/bin/bash
set -eu
set -o pipefail # To handle errors during pipe commands
export AWS_ACCESS_KEY_ID={{ docker_tableau_backups.access_key_id }}
export AWS_SECRET_ACCESS_KEY={{ docker_tableau_backups.secret_access_key }}
export AWS_DEFAULT_REGION={{ docker_tableau_s3_backups.region }}
cd {{ docker_tableau_deploy_dir }}

aws --endpoint-url {{ docker_tableau_s3_backups.endpoint_url }} s3 sync {{ docker_tableau_s3_backups_url }} {{ docker_tableau_backups_dir }}
