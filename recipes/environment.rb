execute_environment = {
    "PATH" => "/usr/local/sbin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin:/opt/certbot-wrapper/bin",
    "HOME" => '/root'
}

cron_environment = {
    "MAILFROM" => node['chef-server']['cron_mailfrom'],
}

if node['chef-server']['aws_access_key_id']
  execute_environment['AWS_ACCESS_KEY_ID'] = node['chef-server']['aws_access_key_id']
  cron_environment['AWS_ACCESS_KEY_ID'] = node['certbot']['aws_access_key_id']
end

if node['chef-server']['aws_secret_access_key']
  execute_environment['AWS_SECRET_ACCESS_KEY'] = node['chef-server']['aws_secret_access_key']
  execute_environment['AWS_DEFAULT_REGION'] = node['chef-server']['aws_region']

  cron_environment['AWS_SECRET_ACCESS_KEY'] = node['certbot']['aws_secret_access_key']
  cron_environment['AWS_DEFAULT_REGION'] = node['certbot']['aws_region']
end

node.run_state['execute_environment'] = execute_environment
node.run_state['cron_environment'] = cron_environment
