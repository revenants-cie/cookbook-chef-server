package 'certbot-wrapper'

directory '/root/.certbot' do
  owner 'root'
  group 'root'
  mode '0700'
end

aws_config_file = '/root/.certbot/aws_config_file'
template aws_config_file do
  source 'aws_config.erb'
  sensitive true
  owner 'root'
  group 'root'
  mode '600'
  variables(
      aws_access_key_id: node['certbot']['aws_access_key_id'],
      aws_secret_access_key: node['certbot']['aws_secret_access_key'],
      aws_region: node['certbot']['aws_region']
  )
end

zone_arg = ""
node['certbot']['zones'].each { |zone|
    zone_arg << " -d chef-server.#{zone}"
}

if node['certbot']['dry_run']
    dry_run_arg = '--dry-run'
else
    dry_run_arg = ''
end

raise "You must accept certbot license by setting attribute node['certbot']['accept_license'] to true" unless node['certbot']['accept_license']

execute_environment = {
    :AWS_CONFIG_FILE => aws_config_file,
    :PATH => "/opt/certbot-wrapper/bin"
}
execute 'obtain_certificates' do
  command "certbot-wrapper #{dry_run_arg} --sleep-delay 0 certonly #{zone_arg} --email #{node['certbot']['ssl_admin_email']}"
  environment execute_environment
  creates '/etc/letsencrypt/live/README'
  action :run
end

cron_environment = {
    :MAILFROM => node['chef-server']['cron_mailfrom'],
    :AWS_CONFIG_FILE =>  aws_config_file,
    :PATH => "/usr/local/sbin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin:/opt/certbot-wrapper/bin"
}

cron 'renew_cert' do
  minute '0'
  hour '0,12'
  command "certbot-wrapper #{dry_run_arg} renew"
  mailto node['chef-server']['cron_mailto']
  environment cron_environment
end

logrotate_app 'certbot' do
    path      '/var/log/certbot.log'
    frequency 'weekly'
    rotate    4
    options 'nocompress'
end
