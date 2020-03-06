#!/usr/bin/env bash

set -eux
rm -rf /var/tmp/letsencrypt
backup_copy=$(twindb-backup ls --type files | grep _etc_letsencrypt- | sort -t / -k 7 | tail -1)

if ! test -z "$backup_copy"
then
  twindb-backup restore file --dst /var/tmp/letsencrypt "$backup_copy"
  cp -R /var/tmp/letsencrypt/etc/letsencrypt /etc/
fi
