node['chef-server']['admins'].each { |usr|
  user usr do
      manage_home true
      gid 0
  end

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

node['chef-server']['ssh_public_keys'].each { |item|
    usr = item[0]
    directory "/home/#{usr}/.ssh" do
        owner usr
        group 0
        mode '0700'
        action :create
    end

    keys = item[1]
    keys.each { |key|
        ssh_authorize_key key["email"] do
            key key["key"]
            user usr
            group 0
        end
    }
}
