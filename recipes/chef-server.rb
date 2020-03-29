raise "You must accept Chef license by setting attribute node['chef-server']['accept_license'] to true" unless node['chef-server']['accept_license']

remote_file "#{Chef::Config[:file_cache_path]}/chef-server-core.rpm" do
  source node['chef-server']['pkg-url']
  checksum node['chef-server']['pkg-sha256sum']
  action :create_if_missing
end

package 'chef-server-core' do
  source "#{Chef::Config[:file_cache_path]}/chef-server-core.rpm"
  notifies :run, 'execute[reconfigure_chef_server]', :immediately
end

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

execute 'restore_chef_server' do
  command "chef-server-wrapper restore-chef-server #{node['twindb-backup']['backups_bucket']}"
  environment environment
  not_if  "chef-server-ctl org-show #{node['chef-server']['org_short_name']}"
  action :run
end

execute 'reconfigure_chef_server' do
  command 'chef-server-ctl reconfigure'
  action :nothing
end

execute 'reconfigure_chef_manage' do
  command 'chef-manage-ctl reconfigure --accept-license'
  action :nothing
end

execute 'install_chef_manage' do
  command 'chef-server-ctl install chef-manage'
  not_if "which chef-manage-ctl"
  action :run
  notifies :run, 'execute[reconfigure_chef_server]', :immediately
  notifies :run, 'execute[reconfigure_chef_manage]', :immediately
end

directory '/var/opt/chef-backup'
execute 'create_organization' do
  command "chef-server-ctl org-create \"#{node['chef-server']['org_short_name']}\" \"#{node['chef-server']['org_full_name']}\" --filename \"/var/opt/chef-backup/#{node['chef-server']['org_short_name']}-validator.pem\""
  not_if  "chef-server-ctl org-show #{node['chef-server']['org_short_name']}"
  action :run
end

file "/var/opt/chef-backup/#{node['chef-server']['org_short_name']}-validator.pem" do
    owner 'root'
    group 'root'
    mode '0640'
end

node['chef-server']['admins'].each { |admin|
  password = SecureRandom.hex

  execute "user_create_#{admin}" do
    sensitive true
    command "chef-server-ctl user-create \"#{admin}\" FIRST_NAME LAST_NAME \"#{admin}@#{node['certbot']['zones'][0]}\" \"#{password}\" --filename \"/home/#{admin}/chef-#{admin}.pem\""
    not_if "chef-server-ctl user-show #{admin}"
    notifies :run, "execute[save_chef_password_#{admin}]", :delayed
    notifies :run, "execute[save_chef_key_#{admin}]", :delayed
  end

  execute "save_chef_password_#{admin}" do
      sensitive true
      environment environment
      command "chef-server-wrapper save-chef-password #{admin} #{password} --region #{node['chef-server']['aws_region']}"
      action :nothing
  end

  execute "save_chef_key_#{admin}" do
      sensitive true
      environment environment
      command "chef-server-wrapper save-chef-user-key --region #{node['chef-server']['aws_region']} #{admin} /home/#{admin}/chef-#{admin}.pem"
      action :nothing
  end
}

node['chef-server']['admins'].each { |admin|
  execute "grant_server_admin_permissions_#{admin}" do
    command "chef-server-ctl grant-server-admin-permissions #{admin}"
    not_if "chef-server-ctl list-server-admins | grep #{admin}"
    action :run
  end
}

node['chef-server']['admins'].each { |admin|
  execute "org_user_add_#{admin}" do
    command "chef-server-ctl org-user-add \"#{node['chef-server']['org_short_name']}\" #{admin} --admin"
    action :run
  end
}

template '/etc/opscode/chef-server.rb' do
    source 'chef-server.erb'
    owner 'root'
    group 'root'
    mode '644'
    variables(
        zone: node['certbot']['zones'][0]
    )
    notifies :run, 'execute[reconfigure_chef_server]', :delayed
end

cron_environment = {
    :MAILFROM => node['chef-server']['cron_mailfrom'],
    :HOME => '/root',
    :PATH => "#{ENV['PATH']}:/opt/certbot-wrapper/bin",
}
if node['chef-server']['aws_access_key_id']
  cron_environment['AWS_ACCESS_KEY_ID'] = node['chef-server']['aws_access_key_id']
end
if node['chef-server']['aws_secret_access_key']
  cron_environment['AWS_SECRET_ACCESS_KEY'] = node['chef-server']['aws_secret_access_key']
  cron_environment['AWS_DEFAULT_REGION'] = node['chef-server']['aws_region']
end


%w(hourly daily weekly monthly yearly).each { |run_type|
  cron "chef-server-backup_#{run_type}" do
    time run_type.to_sym
    command "chef-server-wrapper chef-server-backup #{run_type}"
    mailto node['chef-server']['cron_mailto']
    environment cron_environment
    only_if "chef-server-ctl org-show #{node['chef-server']['org_short_name']}"
  end
}

directory '/etc/chef-manage'
template '/etc/chef-manage/manage.rb' do
    source 'manage.erb'
    owner 'root'
    group 'root'
    mode '644'
    variables(
        zone: node['certbot']['zones'][0]
    )
    notifies :run, 'execute[reconfigure_chef_manage]', :delayed
end


node['chef-server']['admins'].each { |usr|

  directory "/home/#{usr}/.chef" do
    owner usr
    group 0
    mode '0755'
    action :create
  end

  template "/home/#{usr}/.chef/knife.rb" do
    source 'knife.erb'
    mode '0440'
    owner usr
    group 0
    variables(
        username: usr,
        client_key: "/home/#{usr}/.chef/#{usr}.pem",
        validation_client_name: "#{node['chef-server']['org_short_name']}-validator",
        validation_key: "/var/opt/chef-backup/#{node['chef-server']['org_short_name']}-validator.pem",
        chef_server_url: "https://chef-server.#{node['certbot']['zones'][0]}/organizations/#{node['chef-server']['org_short_name']}",
        )
  end

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

  execute 'get_client_key' do
    command "aws-wrapper --region #{node['chef-server']['aws_region']} "\
        " get --secret-id /chef-server/users/#{usr}/key > /home/#{usr}/.chef/#{usr}.pem "\
        " 2> /home/#{usr}/.chef/#{usr}.pem.err"
    environment environment
    creates "/home/#{usr}/.chef/#{usr}.pem"
    action :run
  end

  file "/home/#{usr}/.chef/#{usr}.pem" do
    owner usr
    group 0
    mode '0640'
  end
}
