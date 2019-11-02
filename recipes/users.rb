node['chef-server']['admins'].each { |usr|
  user usr do
      manage_home true
      notifies :run, "execute[user_create_#{usr}]", :delayed
      notifies :run, "execute[grant_server_admin_permissions_#{usr}]", :delayed
      notifies :run, "execute[org_user_add_#{usr}]", :delayed
  end
}
