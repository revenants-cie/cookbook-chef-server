package 'rsync'
package 'twindb-backup'

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

template '/etc/twindb/twindb-backup.cfg' do
    source 'twindb-backup.cfg.erb'
    sensitive true
    owner 'root'
    group 'root'
    mode '600'
    variables(
        aws_access_key_id: node['chef-server']['aws_access_key_id'],
        aws_secret_access_key: node['chef-server']['aws_secret_access_key'],
        aws_default_region: node['chef-server']['aws_region'],
        bucket: node['chef-server']['backups_bucket']
    )
end
