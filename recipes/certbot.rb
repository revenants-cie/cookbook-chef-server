package 'certbot-wrapper' do
    action :upgrade
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

if node['certbot']['test_cert']
    test_cert_arg = '--test-cert'
else
    test_cert_arg = ''
end

if node['certbot']['role_arn'] != nil
  role_arn_arg = "--assume-role #{node['certbot']['role_arn']}"
else
  role_arn_arg = ''
end

raise "You must accept certbot license by setting attribute node['certbot']['accept_license'] to true" unless node['certbot']['accept_license']

environment = {
    :PATH => "#{ENV['PATH']}:/opt/certbot-wrapper/bin",
    :HOME => '/root'
}
if node['certbot']['aws_access_key_id']
  environment['AWS_ACCESS_KEY_ID'] = node['certbot']['aws_access_key_id']
end
if node['certbot']['aws_secret_access_key']
  environment['AWS_SECRET_ACCESS_KEY'] = node['certbot']['aws_secret_access_key']
  environment['AWS_DEFAULT_REGION'] = node['certbot']['aws_region']
end

execute 'obtain_certificates' do
  command "certbot-wrapper #{dry_run_arg} #{test_cert_arg} --sleep-delay 0 #{role_arn_arg} certonly #{zone_arg} --email #{node['certbot']['ssl_admin_email']}"
  environment environment
  creates '/etc/letsencrypt/live/README'
  action :run
end

cron_environment = {
    :MAILFROM => node['chef-server']['cron_mailfrom'],
    :PATH => "/usr/local/sbin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin:/opt/certbot-wrapper/bin"
}
if node['certbot']['aws_access_key_id']
  cron_environment['AWS_ACCESS_KEY_ID'] = node['certbot']['aws_access_key_id']
end
if node['certbot']['aws_secret_access_key']
  cron_environment['AWS_SECRET_ACCESS_KEY'] = node['certbot']['aws_secret_access_key']
  cron_environment['AWS_DEFAULT_REGION'] = node['certbot']['aws_region']
end

cron 'renew_cert' do
  minute '0'
  hour '0,12'
  command "certbot-wrapper #{dry_run_arg} #{test_cert_arg} #{role_arn_arg} renew"
  mailto node['chef-server']['cron_mailto']
  environment cron_environment
end

logrotate_app 'certbot' do
    path      '/var/log/certbot.log'
    frequency 'weekly'
    rotate    4
    options 'nocompress'
end
