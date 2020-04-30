default['chef-server']['org_short_name'] = 'acme'
default['chef-server']['org_full_name'] = 'Acme Corp'
default['chef-server']['admins'] = []
default['chef-server']['ssh_public_keys'] = []
default['chef-server']['required_packages'] = %w(git cronie ntp freetype-devel libpng-devel chef chefdk)
default['chef-server']['optional_packages'] = %w(vim jq screen strace)
default['chef-server']['pkg-url'] = 'https://packages.chef.io/files/stable/chef-server/12.19.31/el/7/chef-server-core-12.19.31-1.el7.x86_64.rpm'
default['chef-server']['pkg-sha256sum'] = '5a49f4e6b62463d1051808795c3ef63f34118286e869a4ef0296fdcddda72868'
default['chef-server']['accept_license'] = nil
default['chef-server']['aws_access_key_id'] = nil
default['chef-server']['aws_secret_access_key'] = nil
default['chef-server']['aws_region'] = 'us-east-1'
default['chef-server']['cron_mailto'] = 'root'
default['chef-server']['cron_mailfrom'] = 'root'
default['chef-server']['notification_email'] = 'root'
default['chef-server']['cookbook_revision'] = 'master'

default['postfix']['relayhost'] = '[email-smtp.us-east-1.amazonaws.com]:587'
default['postfix']['smtp_username'] = nil
default['postfix']['smtp_password'] = nil

default['certbot']['role_arn'] = nil
default['certbot']['aws_access_key_id'] = nil
default['certbot']['aws_secret_access_key'] = nil
default['certbot']['aws_region'] = 'us-east-1'
default['certbot']['zones'] = []
default['certbot']['dry_run'] = false
default['certbot']['ssl_admin_email'] = nil
default['certbot']['accept_license'] = nil

default['artifactory']['baseurl'] = 'https://revenants.jfrog.io/revenants/rpm/$releasever/os/$basearch/'
default['artifactory']['username'] = nil
default['artifactory']['password'] = nil
default['artifactory']['gpgcheck'] = false

default['twindb-backup']['aws_access_key_id'] = nil
default['twindb-backup']['aws_secret_access_key'] = nil
default['twindb-backup']['aws_region'] = 'us-east-1'
default['twindb-backup']['backups_bucket'] = nil

default['revdb']['company_code'] = nil

default['datadog_app_key_secret_id'] = 'datadog_app_key'
default['datadog_api_key_secret_id'] = 'datadog_api_key'
default['datadog_aws_integration_external_id_secret_id'] = 'datadog_aws_integration_external_id'

default['datadog']['enable_process_agent'] = true
default['datadog']['extra_config']['process_config']['strip_proc_arguments'] = 'true'

default['datadog']['tags'] = [
  'env:' + node.chef_environment,
  'dc:' + node['ec2']['region'],
  'az:' + node['ec2']['availability_zone'],
  'ami:' + node['ec2']['ami_id'],
  'instance_id:' + node['ec2']['instance_id'],
  'instance_type:' + node['ec2']['instance_type'],
  'acc:' + node['ec2']['account_id'],
  'fqdn:' + node['fqdn'],
  'company_code:' + node['revdb']['company_code']
]
