#!/usr/bin/env python
"""
aws secretsmanager create-secret \
    --name /chef-server/users/#{admin}/key \
    --description 'Client key for #{admin} account on Chef Server' \
    --secret-string #{password}
"""
from __future__ import print_function

import sys
import boto3
from botocore.exceptions import ClientError

try:
    username = sys.argv[1]
    path = sys.argv[2]
    region = sys.argv[3]
except IndexError:
    print("Usage: %s username /path/to/chef-client-key.pem aws_region" % sys.argv[0])
    sys.exit(1)


client = boto3.client(
    'secretsmanager',
    region_name=region
)
secret_id = "/chef-server/users/{user}/key".format(
    user=username
)
description = "Client key for {user} account on Chef Server".format(
    user=username
)
password = open(path).read()

try:
    client.create_secret(
        Name=secret_id,
        SecretString=password,
        Description=description
    )
except ClientError as err:
    if err.response['Error']['Code'] == 'ResourceExistsException':
        client.update_secret(
            SecretId=secret_id,
            SecretString=password,
            Description=description
        )
    else:
        raise
