# https://docs.aws.amazon.com/ses/latest/DeveloperGuide/postfix.html
# The Chef Infra Server uses email to send notifications for various events;
# a local mail transfer agent should be installed
# and available to the Chef server

%w(postfix mailx cyrus-sasl-plain).each { |pkg|
  package pkg
}

template '/etc/postfix/main.cf' do
  source 'main.cf.erb'
  owner 'root'
  group 'root'
  mode '0644'
  variables(
      relayhost: node['postfix']['relayhost'],
  )
  notifies :restart, 'service[postfix]', :delayed
end

template '/etc/postfix/sasl_passwd' do
  source 'sasl_passwd.erb'
  sensitive true
  owner 'root'
  group 'root'
  mode '0600'
  variables(
      relayhost: node['postfix']['relayhost'],
      smtp_username: node['postfix']['smtp_username'],
      smtp_password: node['postfix']['smtp_password']
      )
  notifies :run, 'execute[remap_sasl_passwd]', :immediately
  notifies :restart, 'service[postfix]', :delayed
end

execute 'remap_sasl_passwd' do
  command 'postmap hash:/etc/postfix/sasl_passwd'
  action :nothing
end

file '/etc/postfix/sasl_passwd.db' do
  mode '0600'
  owner 'root'
  group 'root'
end

service 'postfix' do
  action :start
end
