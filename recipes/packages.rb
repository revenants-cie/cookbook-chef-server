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
