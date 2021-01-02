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
    description 'Chef software repository'
    gpgcheck true
    gpgkey 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CHEF'
end

yum_repository 'revdb_artifactory' do
  baseurl     'https://revenants.jfrog.io/artifactory/rpm-local/$releasever/os/$basearch/'
  description 'RevDB repository'
  gpgcheck    false
  mode '0640'
end

package 'epel-release' do
    action :upgrade
end
