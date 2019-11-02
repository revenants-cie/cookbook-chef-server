remote_file "#{Chef::Config[:file_cache_path]}/chef-server-core.rpm" do
  source node['chef-server']['pkg-url']
  checksum node['chef-server']['pkg-sha256sum']
  action :create_if_missing
end

package 'chef-server-core' do
  source "#{Chef::Config[:file_cache_path]}/chef-server-core.rpm"
  notifies :run, 'execute[reconfigure_chef_server]', :immediately
  notifies :run, 'execute[install_chef_manage]', :immediately
  notifies :run, 'execute[create_organization]', :immediately
end

execute 'install_chef_manage' do
  command 'chef-server-ctl install chef-manage'
  action :nothing
  notifies :run, 'execute[reconfigure_chef_server]', :immediately
  notifies :run, 'execute[reconfigure_chef_manage]', :immediately
end

execute 'reconfigure_chef_server' do
  command 'chef-server-ctl reconfigure'
  action :nothing
end

raise "You must accept Chef license by setting attribute node['chef-server']['accept_license'] to true" unless node['chef-server']['accept_license']

execute 'reconfigure_chef_manage' do
  command 'chef-manage-ctl reconfigure --accept-license'
  action :nothing
end

execute 'create_organization' do
  command "chef-server-ctl org-create \"#{node['chef-server']['org_short_name']}\" \"#{node['chef-server']['org_full_name']}\" --filename \"/root/#{node['chef-server']['org_short_name']}-validator.pem\""
  action :nothing
end

node['chef-server']['admins'].each { |admin|
  execute "user_create_#{admin}" do
    command "chef-server-ctl user-create \"#{admin}\" FIRST_NAME LAST_NAME \"#{admin}@#{node['certbot']['zones'][0]}\" \"qwerty\" --filename \"/home/#{admin}/chef-#{admin}.pem\""
    action :nothing
  end
}

node['chef-server']['admins'].each { |admin|
  execute "grant_server_admin_permissions_#{admin}" do
    command "chef-server-ctl grant-server-admin-permissions #{admin}"
    action :nothing
  end
}

node['chef-server']['admins'].each { |admin|
  execute "org_user_add_#{admin}" do
    command "chef-server-ctl org-user-add \"#{node['chef-server']['org_short_name']}\" #{admin}"
    action :nothing
  end
}
