execute 'accept_license' do
  command "CHEF_LICENSE=accept chef env"
  action :nothing
end
