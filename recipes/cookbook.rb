cookbooks_dir = '/var/cache/cookbooks'
directory cookbooks_dir

git 'cookbook-chef-server' do
  repository 'https://github.com/revenants-cie/cookbook-chef-server.git'
  destination "#{cookbooks_dir}/chef-server"
  revision node['chef-server']['cookbook_revision']
  notifies :run, 'execute[pull_cookbook_dependencies]', :immediately
end

execute 'pull_cookbook_dependencies' do
  command "chef exec berks vendor ../"
  cwd "#{cookbooks_dir}/chef-server"
  notifies :run, 'execute[accept_license]', :before
  action :nothing
end
