execute 'restore_certificates' do
    command "/opt/certbot-wrapper/bin/chef-server-wrapper restore-certificates  #{node['chef-server']['backups_bucket']}"
    not_if { File.directory?('/etc/letsencrypt') }
    action :run
end
