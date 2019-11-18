#!/usr/bin/env bash

set -euo pipefail

trap print_err ERR

function print_err() {
    echo "$OUTPUT"
}

run_type=$1

OUTPUT=$(
  {
    chef-server-ctl reconfigure ;
    chef-server-ctl backup --yes
    # delete backups older than 7 days
    find /var/opt/chef-backup -type f -ctime 7 -delete
    twindb-backup backup "$run_type"
  } 2>&1 | tee -a /var/log/chef-server-backup.log
)
