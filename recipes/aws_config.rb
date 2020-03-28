directory '/root/.aws' do
  owner 'root'
  group 'root'
  mode '0700'
end

template '/root/.aws/config' do
  source 'aws_config.erb'
  sensitive true
  owner 'root'
  group 'root'
  mode '600'
  variables(
      aws_region: node['chef-server']['aws_region']
  )
end
