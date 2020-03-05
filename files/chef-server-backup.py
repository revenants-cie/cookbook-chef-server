#!/usr/bin/env python
import fcntl
from os import environ
import socket
from subprocess import Popen
import sys
from textwrap import dedent

LOG_FILE = "/var/log/chef-server-backup.log"
LOCK_FILE = "/var/run/twindb-backup.lock"


def main():
    for cmd in [
        ["chef-server-ctl", "reconfigure"],
        ["chef-server-ctl", "backup", "--yes"],
        ["find", "/var/opt/chef-backup", "-type", "f", "-ctime", "1", "-delete"],
    ]:
        _execute(cmd)


def _execute(cmd):

    with open(LOG_FILE, "a") as log_desc:
        proc = Popen(cmd, stdout=log_desc, stderr=log_desc, env=environ)
        proc.communicate()
        if proc.returncode:
            print(
                "%s exited with non-zero. Check %s on %s."
                % (" ".join(cmd), LOG_FILE, socket.gethostname())
            )
            sys.exit(1)


if __name__ == "__main__":
    try:
        with open(LOCK_FILE, "w") as fp:
            fcntl.flock(fp, fcntl.LOCK_EX)
            main()

        _execute(["twindb-backup", "backup", sys.argv[1]])

    except IndexError:
        print(
            dedent(
                """
                Usage:
                    {cmd} hourly|daily|weekly|monthly|yearly
                """.format(
                    cmd=sys.argv[0]
                )
            )
        )
