raise "You must accept Chef license by setting attribute node['chef-server']['accept_license'] to true" unless node['chef-server']['accept_license']

directory '/root/.aws' do
    owner 'root'
    group 'root'
    mode '0700'
end

aws_config_file = '/root/.aws/config'
template aws_config_file do
    source 'aws_config.erb'
    sensitive true
    owner 'root'
    group 'root'
    mode '600'
    variables(
        aws_access_key_id: node['chef-server']['aws_access_key_id'],
        aws_secret_access_key: node['chef-server']['aws_secret_access_key'],
        aws_region: node['chef-server']['aws_region']
    )
end
python_package 'awscli'
python_package 'boto3'

execute 'restore_chef_server' do
    command "/usr/local/bin/restore_chef_server"
    not_if  "chef-server-ctl org-show #{node['chef-server']['org_short_name']}"
    action :run
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
      environment(
        'HOME' => '/root',
        'AWS_CONFIG_FILE' => '/root/.aws/config'
      )
      command "/usr/local/bin/update_chef_password #{admin} #{password} #{node['chef-server']['aws_region']}"
      action :nothing
  end

  execute "save_chef_key_#{admin}" do
      sensitive true
      environment(
          'HOME' => '/root',
          'AWS_CONFIG_FILE' => '/root/.aws/config'
      )
      command "/usr/local/bin/update_chef_user_key #{admin} /home/#{admin}/chef-#{admin}.pem #{node['chef-server']['aws_region']}"
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
    only_if { File.exists?("/etc/letsencrypt/live/chef-server.#{node['certbot']['zones'][0]}/fullchain.pem") }
    notifies :run, 'execute[reconfigure_chef_server]', :delayed
end
