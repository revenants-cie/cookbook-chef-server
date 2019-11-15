node['chef-server']['admins'].each { |usr|
  user usr do
      manage_home true
  end
}
