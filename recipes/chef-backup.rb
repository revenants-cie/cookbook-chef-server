package 'rsync'

cookbook_file '/usr/local/bin/check-server-backup.sh' do
    source 'check-server-backup.sh'
    mode '0755'
    owner 'root'
    group 'root'
end

cron 'chef-server-backup' do
    time :daily
    command 'OUTPUT=$(/usr/local/bin/check-server-backup.sh 2>&1 | tee -a /var/log/check-server-backup.log) || echo "$OUTPUT"'
    mailto node['chef-server']['cron_mailto']
end

logrotate_app 'chef-server-backup' do
    path      '/var/log/check-server-backup.log'
    frequency 'weekly'
    rotate    4
    options 'nocompress'
end
