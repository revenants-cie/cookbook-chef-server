package 'epel-release' do
    action :upgrade
end

package 'certbot'
package 'python2-certbot-dns-route53' do
  options '--setopt=obsoletes=0'
end

directory '/root/.certbot' do
  owner 'root'
  group 'root'
  mode '0700'
end

aws_config_file = '/root/.certbot/aws_config_file'
template aws_config_file do
  source 'aws_config.erb'
  sensitive true
  owner 'root'
  group 'root'
  mode '600'
  variables(
      aws_access_key_id: node['certbot']['aws_access_key_id'],
      aws_secret_access_key: node['certbot']['aws_secret_access_key'],
      aws_region: node['certbot']['aws_region']
  )
end

zone_arg = node['certbot']['zones'].join(' -d chef-server.')

if node['certbot']['dry_run']
    dry_run_arg = '--dry-run'
    echo_if_dry_run = "echo Would execute if not dry-run: "
else
    dry_run_arg = ''
    echo_if_dry_run = ""
end

raise "You must accept certbot license by setting attribute node['certbot']['accept_license'] to true" unless node['certbot']['accept_license']

execute 'obtain_certificates' do
  command "#{echo_if_dry_run}AWS_CONFIG_FILE=#{aws_config_file} certbot certonly --dns-route53 -d chef-server.#{zone_arg} --agree-tos --email #{node['certbot']['ssl_admin_email']} #{dry_run_arg}"
  not_if { File.directory?('/etc/letsencrypt/live') }
  action :run
end

cron 'renew_cert' do
  minute '0'
  hour '0,12'
  command "python -c 'import random; import time; time.sleep(random.random() * 3600)' && AWS_CONFIG_FILE=#{aws_config_file} certbot renew #{dry_run_arg}"
end
