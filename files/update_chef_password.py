#!/usr/bin/env python
"""
aws secretsmanager create-secret \
    --name /chef-server/users/#{admin}/credentials \
    --description 'Password for #{admin} account on Chef Server' \
    --secret-string #{password}
"""
from __future__ import print_function

import json
import sys
import boto3
from botocore.exceptions import ClientError

try:
    username = sys.argv[1]
    password = sys.argv[2]
    region = sys.argv[3]
except IndexError:
    print("Usage: %s username password aws_region" % sys.argv[0])
    sys.exit(1)


client = boto3.client(
    'secretsmanager',
    region_name=region
)
secret_id = "/chef-server/users/{user}/credentials".format(
    user=username
)
description = "{user} account credentials on Chef Server".format(
    user=username
)
credentials = {
    'user': username,
    'password': password
}
try:
    client.create_secret(
        Name=secret_id,
        SecretString=json.dumps(credentials),
        Description=description
    )
except ClientError as err:
    if err.response['Error']['Code'] == 'ResourceExistsException':
        client.update_secret(
            SecretId=secret_id,
            SecretString=json.dumps(credentials),
            Description=description
        )
    else:
        raise
