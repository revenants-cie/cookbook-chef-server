cron_environment = {
    :MAILFROM => node['chef-server']['cron_mailfrom'],
    :HOME => '/root',
    :PATH => "/usr/local/sbin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin:/opt/certbot-wrapper/bin",
}

cron 'chef-solo' do
    minute '*/30'
    command "chef-server-wrapper chef-solo"
    mailto node['chef-server']['cron_mailto']
    environment cron_environment
    notifies :run, 'execute[accept_license]', :before
end

logrotate_app 'chef-solo' do
    path      '/var/log/chef-solo.log'
    frequency 'weekly'
    rotate    4
    options 'nocompress'
end
