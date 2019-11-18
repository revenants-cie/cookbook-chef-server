node['chef-server']['required_packages'].each { |pkg|
  package pkg
}

node['chef-server']['optional_packages'].each { |pkg|
    package pkg
}

%w(update_chef_password update_chef_user_key).each { |tool|
    cookbook_file "/usr/local/bin/#{tool}" do
        source "#{tool}.py"
        mode '0755'
        owner 'root'
        group 'root'
    end
}

remote_file "#{Chef::Config[:file_cache_path]}/chef-server-core.rpm" do
    source node['chef-server']['pkg-url']
    checksum node['chef-server']['pkg-sha256sum']
    action :create_if_missing
end

execute 'reconfigure_chef_server' do
    command 'chef-server-ctl reconfigure'
    action :nothing
end

package 'chef-server-core' do
    source "#{Chef::Config[:file_cache_path]}/chef-server-core.rpm"
    notifies :run, 'execute[reconfigure_chef_server]', :immediately
end
