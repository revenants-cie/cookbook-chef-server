#!/usr/bin/env bash

set -e

function usage() {
    echo "Usage: "
    echo ""
    echo "$0 BUCKET_NAME"
    exit 1
}

! test -z "$1" || usage

set -u
bucket=$1
rm -rf /var/tmp/letsencrypt

aws s3 ls s3://"$bucket" || echo "Failed to list bucket $bucket. Skipping restoring Chef server." ; exit 0

tmpdir="$(mktemp -d)"

function cleanup() {
    rf -rf "$tmpdir"
}

backup_copy=$(twindb-backup ls --type files | grep _var_opt_chef-backup | sort -t / -k 7 | tail -1)
if ! test -z "$backup_copy"
then
  twindb-backup restore file --dst "$tmpdir" "$backup_copy"
fi

chef_server_backup=$(find "$tmpdir" -type f -name "*.tgz" | sort | tail -1)

if ! test -z "$chef_server_backup"
then
  chef-server-ctl cleanse
  chef-server-ctl restore "$chef_server_backup"
  chef-server-ctl reconfigure
fi
