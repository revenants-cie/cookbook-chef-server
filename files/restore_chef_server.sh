#!/usr/bin/env bash

set -eux
rm -rf /var/tmp/chef-server
backup_copy=$(twindb-backup ls --type files | grep _var_opt_chef-backup | sort -t / -k 7 | tail -1)
if ! test -z "$backup_copy"
then
  twindb-backup restore file --dst /var/tmp/chef-server "$backup_copy"
fi

chef_server_backup=$(find /var/tmp/chef-server/var/opt/chef-backup/ -type f -name "*.tar.gz" | sort  | tail -1)
if ! test -z "$chef_server_backup"
then
  chef-server-ctl cleanse
  chef-server-ctl restore "$chef_server_backup"
fi
