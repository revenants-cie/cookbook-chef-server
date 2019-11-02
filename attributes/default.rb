default['chef-server']['org_short_name'] = 'acme'
default['chef-server']['org_full_name'] = 'Acme Corp'
default['chef-server']['admins'] = []
default['chef-server']['required_packages'] = %w(git cronie ntp freetype-devel libpng-devel)
default['chef-server']['optional_packages'] = %w(vim)
default['chef-server']['pkg-url'] = 'https://packages.chef.io/files/stable/chef-server/12.19.31/el/7/chef-server-core-12.19.31-1.el7.x86_64.rpm'
default['chef-server']['pkg-sha256sum'] = '5a49f4e6b62463d1051808795c3ef63f34118286e869a4ef0296fdcddda72868'
default['chef-server']['accept_license'] = nil

default['postfix']['relayhost'] = '[email-smtp.us-east-1.amazonaws.com]:587'
default['postfix']['smtp_username'] = nil
default['postfix']['smtp_password'] = nil

default['certbot']['aws_access_key_id'] = nil
default['certbot']['aws_secret_access_key'] = nil
default['certbot']['zones'] = []
default['certbot']['dry_run'] = true
default['certbot']['ssl_admin_email'] = nil
default['certbot']['accept_license'] = nil
