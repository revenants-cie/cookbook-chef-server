package 'rsync'
package 'twindb-backup' do
    action :upgrade
end

file '/etc/cron.d/twindb-backup' do
    action :delete
end

logrotate_app 'chef-server-backup' do
    path      '/var/log/chef-server-backup.log'
    frequency 'weekly'
    rotate    4
    options %w(nocompress missingok)
end

directory '/etc/twindb'
template '/etc/twindb/twindb-backup.cfg' do
    source 'twindb-backup.cfg.erb'
    sensitive true
    owner 'root'
    group 'root'
    mode '600'
    variables(
        aws_access_key_id: node['twindb-backup']['aws_access_key_id'],
        aws_secret_access_key: node['twindb-backup']['aws_secret_access_key'],
        aws_default_region: node['twindb-backup']['aws_region'],
        bucket: node['twindb-backup']['backups_bucket']
    )
end
