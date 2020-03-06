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

  execute 'get_client_key' do
      command "aws secretsmanager get-secret-value "\
        "--region #{node['chef-server']['aws_region']} "\
        "--secret-id /chef-server/users/#{usr}/key "\
        "| jq -r .SecretString > /home/#{usr}/.chef/#{usr}.pem"
      creates "/home/#{usr}/.chef/#{usr}.pem"
      action :run
  end

  file "/home/#{usr}/.chef/#{usr}.pem" do
      owner usr
      group 0
      mode '0640'
  end
}
