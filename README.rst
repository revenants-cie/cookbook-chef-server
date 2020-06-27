===========
chef-server
===========
.. image:: https://readthedocs.com/projects/revdb-cookbook-chef-server/badge/?version=latest&token=6c90d9c0bf9976627b35fd02009a55980f43f1aa9f097ed20b9a9d5d16625631
    :target: https://revdb-cookbook-chef-server.readthedocs-hosted.com/en/latest/?badge=latest
    :alt: Documentation Status

The cookbook installs and configures a Chef server in AWS

Requirements
============

Platforms
~~~~~~~~~

* CentOS 7

Chef
~~~~

* Chef >= 13.0

Attributes
==========

+----------------------------------------------+---------------------------------------------------------------------------------------------------------------------------------------------+---------+------------------------------------------------------------------------------------------------------------+
| Attribute                                    | Description                                                                                                                                 | Type    | Default                                                                                                    |
+==============================================+=============================================================================================================================================+=========+============================================================================================================+
| ``node['chef-server']['accept_license']``    | Set it to ``true`` if you agree to the Chef license.                                                                                        | Boolean | ``nil``                                                                                                    |
+----------------------------------------------+---------------------------------------------------------------------------------------------------------------------------------------------+---------+------------------------------------------------------------------------------------------------------------+
| ``node['chef-server']['admins']``            | Array of admin usernames.                                                                                                                   |         |                                                                                                            |
|                                              | It will be used to create both system account and account on the Chef Server.                                                               | Array   | ``[]``                                                                                                     |
+----------------------------------------------+---------------------------------------------------------------------------------------------------------------------------------------------+---------+------------------------------------------------------------------------------------------------------------+
| ``node['chef-server']['pkg-url']``           | URL of RPM with Chef Server RPM.                                                                                                            | String  | https://packages.chef.io/files/stable/chef-server/12.19.31/el/7/chef-server-core-12.19.31-1.el7.x86_64.rpm |
+----------------------------------------------+---------------------------------------------------------------------------------------------------------------------------------------------+---------+------------------------------------------------------------------------------------------------------------+
| ``node['chef-server']['pkg-sha256sum']``     | SHA256 checksum on the Chef Server RPM.                                                                                                     | String  | ``5a49f4e6b62463d1051808795c3ef63f34118286e869a4ef0296fdcddda72868``                                       |
+----------------------------------------------+---------------------------------------------------------------------------------------------------------------------------------------------+---------+------------------------------------------------------------------------------------------------------------+
| ``node['postfix']['relayhost']``             | Hostname and port of a mail relay. The local Postfix will use this relay to forward mails from the Chef Server.                             | String  | ``[email-smtp.us-east-1.amazonaws.com]:587``                                                               |
+----------------------------------------------+---------------------------------------------------------------------------------------------------------------------------------------------+---------+------------------------------------------------------------------------------------------------------------+
| ``node['postfix']['smtp_username']``         | SMTP username that will be used to authenticate on the relayhost.                                                                           |         |                                                                                                            |
|                                              | See `Amazon instructions on how to obtain SMTP credentials <https://docs.aws.amazon.com/ses/latest/DeveloperGuide/smtp-credentials.html>`_. | String  | ``nil``                                                                                                    |
+----------------------------------------------+---------------------------------------------------------------------------------------------------------------------------------------------+---------+------------------------------------------------------------------------------------------------------------+
| ``node['postfix']['smtp_password']``         | SMTP password that will be used to authenticate on the relayhost.                                                                           |         |                                                                                                            |
|                                              | See `Amazon instructions on how to obtain SMTP credentials <https://docs.aws.amazon.com/ses/latest/DeveloperGuide/smtp-credentials.html>`_. | String  | ``nil``                                                                                                    |
+----------------------------------------------+---------------------------------------------------------------------------------------------------------------------------------------------+---------+------------------------------------------------------------------------------------------------------------+
| ``node['certbot']['aws_access_key_id']``     | certbot will use this Amazon AWS key to create verification records in zones where the Chef Server will operate.                            |         |                                                                                                            |
|                                              | See `certbot-dns-route53’s documentation <https://certbot-dns-route53.readthedocs.io/en/stable/>`_.                                         | String  | ``nil``                                                                                                    |
+----------------------------------------------+---------------------------------------------------------------------------------------------------------------------------------------------+---------+------------------------------------------------------------------------------------------------------------+
| ``node['certbot']['aws_secret_access_key']`` | The secret part of the certbot AWS key.                                                                                                     | String  | ``nil``                                                                                                    |
+----------------------------------------------+---------------------------------------------------------------------------------------------------------------------------------------------+---------+------------------------------------------------------------------------------------------------------------+

Usage
=====

Using with Chef Solo
~~~~~~~~~~~~~~~~~~~~

You bootstrap a Chef Server probably because you don't have one yet. This cookbook
can be used to start a new standalone Chef Server with Chef Solo.

Using with another Chef Server
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

After initial configuration this cookbook can be used to maintain the configuration of the Chef Server itself.

Recipes
=======

default
~~~~~~~
The default recipe includes all below mentioned recipes.

users
~~~~~
Configures system users.

packages
~~~~~~~~

Installs Chef Server requirements and other packages.

certbot
~~~~~~~

Installs certbot, obtains SSL certificates and configures the certificates renewal.

chef-server
~~~~~~~~~~~

Install and configures the Chef Server itself.

mail-relay
~~~~~~~~~~

Configures local Postfix so the Chef Server can send emails.
