cookbook_file "/etc/pki/rpm-gpg/RPM-GPG-KEY-CHEF" do
    source "RPM-GPG-KEY-CHEF"
    mode '0644'
    owner 'root'
    group 'root'
end

# This repo is created by cloud-init as well.
# in a sense, it's a redundant configuration
# but let's keep in chef
yum_repository 'chef_stable' do
    baseurl 'https://packages.chef.io/repos/yum/stable/el/$releasever/$basearch/'
    gpgcheck true
    gpgkey 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CHEF'
end

yum_repository 'artifactory' do
    baseurl node['artifactory']['baseurl']
    username node['artifactory']['username']
    password node['artifactory']['password']
    gpgcheck node['artifactory']['gpgcheck']
    mode '0600'
    sensitive true
end

package 'epel-release' do
    action :upgrade
end
