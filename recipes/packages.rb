node['chef-server']['required_packages'].each { |pkg|
  package pkg
}

node['chef-server']['optional_packages'].each { |pkg|
    package pkg
}

package 'certbot-wrapper' do
    action :upgrade
end
