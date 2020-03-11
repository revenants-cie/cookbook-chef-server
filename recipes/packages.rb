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
