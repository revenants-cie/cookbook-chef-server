package 'awscli' do
  action :remove
  ignore_failure true
end

directory '/root/.aws' do
  mode '0750'
  owner 'root'
  group 'root'
end

template '/root/.aws/config' do
  source 'dot_aws.erb'
  mode '0640'
  owner 'root'
  group 'root'
  sensitive true
  variables(
    aws_region: node['ec2']['region']
  )
end

apt_update 'update' if node[:platform] == 'ubuntu'

package 'python3'
package 'python3-pip'

execute 'install_awscli' do
  creates '/usr/local/bin/aws'
  command 'pip3 install awscli'
end
