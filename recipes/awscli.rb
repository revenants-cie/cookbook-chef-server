package 'awscli' do
  action :remove
  ignore_failure true
end

apt_update 'update' if node['platform'] == 'ubuntu'

package 'python3'
package 'python3-pip'

execute 'install_awscli' do
  creates '/usr/local/bin/aws'
  command 'pip3 install awscli'
end
