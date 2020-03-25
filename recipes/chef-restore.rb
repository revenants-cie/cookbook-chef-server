execute 'restore_certificates' do
    command "/opt/certbot-wrapper/bin/chef-server-wrapper restore-certificates  #{node['chef-server']['backups_bucket']}"
    environment(
        'HOME' => '/root',
        'AWS_CONFIG_FILE' => '/root/.aws/config'
    )
    not_if { File.directory?('/etc/letsencrypt') }
    action :run
end
