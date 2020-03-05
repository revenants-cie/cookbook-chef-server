#!/usr/bin/env python
import socket
from subprocess import Popen

import sys

import fcntl

CHEF_SOLO_LOG_FILE = "/var/log/chef-solo.log"
LOCK_FILE = "/var/run/twindb-backup.lock"


def main():
    with open(CHEF_SOLO_LOG_FILE, "a") as fp:
        proc = Popen(
            ["chef-solo", "-j", "/etc/chef/node.json", "-c", "/etc/chef/solo.rb"],
            stdout=fp,
            stderr=fp,
        )
        proc.communicate()
        if proc.returncode:
            print(
                "chef-solo exited with non-zero. Check %s on %s."
                % (CHEF_SOLO_LOG_FILE, socket.gethostname())
            )
            sys.exit(1)


if __name__ == "__main__":
    with open(LOCK_FILE, 'w') as fp:
        fcntl.flock(fp, fcntl.LOCK_EX)
        main()
