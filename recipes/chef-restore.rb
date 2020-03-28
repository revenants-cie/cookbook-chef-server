environment = {
    :PATH => "#{ENV['PATH']}:/opt/certbot-wrapper/bin",
    :HOME => '/root'
}

if node['chef-server']['aws_access_key_id']
  environment['AWS_ACCESS_KEY_ID'] = node['chef-server']['aws_access_key_id']
end
if node['chef-server']['aws_secret_access_key']
  environment['AWS_SECRET_ACCESS_KEY'] = node['chef-server']['aws_secret_access_key']
  environment['AWS_DEFAULT_REGION'] = node['chef-server']['aws_region']
end

execute 'restore_certificates' do
    command "chef-server-wrapper restore-certificates  #{node['chef-server']['backups_bucket']}"
    environment environment
    not_if { File.directory?('/etc/letsencrypt') }
    action :run
end
