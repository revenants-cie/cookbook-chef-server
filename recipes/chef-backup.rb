package 'rsync'
package 'twindb-backup' do
    action :upgrade
end

file '/etc/cron.d/twindb-backup' do
    action :delete
end

cookbook_file '/usr/local/bin/chef-server-backup' do
    source 'chef-server-backup.py'
    mode '0755'
    owner 'root'
    group 'root'
end

logrotate_app 'chef-server-backup' do
    path      '/var/log/chef-server-backup.log'
    frequency 'weekly'
    rotate    4
    options 'nocompress'
end

directory '/etc/twindb'
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

%w(hourly daily weekly monthly yearly).each { |run_type|
    cron "chef-server-backup_#{run_type}" do
        time run_type.to_sym
        command "/usr/local/bin/chef-server-backup #{run_type}"
        mailto node['chef-server']['cron_mailto']
        only_if "chef-server-ctl org-show #{node['chef-server']['org_short_name']}"
    end
}
