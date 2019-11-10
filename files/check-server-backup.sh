#!/usr/bin/env bash

set -eu
chef-server-ctl reconfigure
chef-server-ctl backup --yes
# delete backups older than 7 days
find /var/opt/chef-backup -type f -ctime 7 -delete
