cleanup_script_path = "/usr/local/bin/clean-up-nodes"
cookbook_file cleanup_script_path do
  source "cleanup-nodes.sh"
  mode '0755'
  owner 'root'
  group 'root'
end

cron 'cleanup-nodes' do
  minute '45'
  hour '1'
  command cleanup_script_path
  mailto node['chef-server']['cron_mailto']
  path "/usr/local/sbin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin:/opt/certbot-wrapper/bin"
  user node['chef-server']['admins'][0]
  environment node.run_state['cron_environment']
  notifies :run, 'execute[accept_license]', :before
end
