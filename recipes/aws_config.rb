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
