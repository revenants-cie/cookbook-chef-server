cert_file = "/etc/letsencrypt/live/chef-server.#{node['certbot']['zones'][0]}/cert.pem"

execute 'restore_certificates' do
    command "chef-server-wrapper restore-certificates  #{node['twindb-backup']['backups_bucket']}"
    environment node.run_state['execute_environment']
    not_if { File.exists?(cert_file) }
    notifies :run, 'execute[assert_certificate_symlink]', :immediately
    action :run
end

execute 'assert_certificate_symlink' do
  command "test -L #{cert_file}"
  only_if { File.exists?(cert_file) }
  action :nothing
end
