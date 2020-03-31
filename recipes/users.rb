node['chef-server']['admins'].each { |usr|
  user usr do
      manage_home true
      gid 0
  end
  sudo usr do
    user usr
    nopasswd true
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
