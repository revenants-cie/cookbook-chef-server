environment = {
    :PATH => "/usr/local/sbin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin:/opt/certbot-wrapper/bin",
    :HOME => '/root'
}

if node['chef-server']['aws_access_key_id']
  environment['AWS_ACCESS_KEY_ID'] = node['chef-server']['aws_access_key_id']
end
if node['chef-server']['aws_secret_access_key']
  environment['AWS_SECRET_ACCESS_KEY'] = node['chef-server']['aws_secret_access_key']
  environment['AWS_DEFAULT_REGION'] = node['chef-server']['aws_region']
end

cert_file = "/etc/letsencrypt/live/chef-server.#{node['certbot']['zones'][0]}/cert.pem"

execute 'restore_certificates' do
    command "chef-server-wrapper restore-certificates  #{node['twindb-backup']['backups_bucket']}"
    environment environment
    not_if { File.exists?(cert_file) }
    notifies :run, 'execute[assert_certificate_symlink]', :immediately
    action :run
end

execute 'assert_certificate_symlink' do
  command "test -L #{cert_file}"
  only_if { File.exists?(cert_file) }
  action :nothing
end
