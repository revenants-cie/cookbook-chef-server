remote_file "#{Chef::Config[:file_cache_path]}/chef-15.4.45-1.el7.x86_64.rpm" do
    source 'https://packages.chef.io/files/stable/chef/15.4.45/el/7/chef-15.4.45-1.el7.x86_64.rpm'
    checksum '354f91646b7045d695d7965e75cc9253c53ff727b10ac4993e3c63d2ce679a30'
    action :create_if_missing
end

remote_file "#{Chef::Config[:file_cache_path]}/chefdk-4.5.0-1.el7.x86_64.rpm" do
    source 'https://packages.chef.io/files/stable/chefdk/4.5.0/el/7/chefdk-4.5.0-1.el7.x86_64.rpm'
    checksum '21aea090ca864f5d860e6c85d699d3acc4bb2c4c007baf0c37b939685b764979'
    action :create_if_missing
end

package 'chef' do
    source "#{Chef::Config[:file_cache_path]}/chef-15.4.45-1.el7.x86_64.rpm"
    notifies :run, 'execute[accept_license]', :immediately
end

package 'chefdk' do
    source "#{Chef::Config[:file_cache_path]}/chefdk-4.5.0-1.el7.x86_64.rpm"
    notifies :run, 'execute[accept_license]', :immediately
end

execute 'accept_license' do
  command "CHEF_LICENSE=accept chef env"
    action :nothing
end

cookbooks_dir = '/var/cache/cookbooks'
directory cookbooks_dir

git 'cookbook-chef-server' do
    repository 'https://github.com/revenants-cie/cookbook-chef-server.git'
    destination "#{cookbooks_dir}/chef-server"
    revision 'master'
end

execute 'pull_cookbook_dependencies' do
    command "chef exec berks vendor ../"
    cwd "#{cookbooks_dir}/chef-server"
end

chef_solo_wrapper_path = '/usr/local/bin/chef-solo.py'
cookbook_file chef_solo_wrapper_path do
    source 'chef-solo.py'
    mode '0755'
    owner 'root'
    group 'root'
end

cron 'chef-solo' do
    minute '*/30'
    command chef_solo_wrapper_path
    mailto node['chef-server']['cron_mailto']
    environment(
        {
            :MAILFROM => node['chef-server']['cron_mailfrom']
        }
    )
end

logrotate_app 'chef-solo' do
    path      '/var/log/chef-solo.log'
    frequency 'weekly'
    rotate    4
    options 'nocompress'
end
