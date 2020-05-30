# frozen_string_literal: true

ruby_block "get_datadog_api_key_from_asm" do
    block do
      path = ENV['PATH'].split(':')
      path << '/usr/local/bin'
      ENV['PATH'] = path.uniq.join(':')
      ENV['HOME'] = '/root'
      secret_id = node['datadog_api_key_secret_id']
      cmd = Mixlib::ShellOut.new(
          'aws secretsmanager get-secret-value '\
          "--secret-id #{secret_id} "\
          "--output text --query SecretString"
      ).run_command
      Chef::Application.fatal!(cmd.stderr) unless cmd.exitstatus.zero?
      node.default['datadog']['api_key'] = cmd.stdout.strip
    end
    action :run
end

ruby_block 'get_datadog_app_key_from_asm' do
  block do
    path = ENV['PATH'].split(':')
    path << '/usr/local/bin'
    ENV['PATH'] = path.uniq.join(':')
    ENV['HOME'] = '/root'
    secret_id = node['datadog_app_key_secret_id']
    cmd = Mixlib::ShellOut.new(
      'aws secretsmanager get-secret-value '\
      "--secret-id #{secret_id} "\
      '--output text --query SecretString'
    ).run_command
    Chef::Application.fatal!(cmd.stderr) unless cmd.exitstatus.zero?
    node.default['datadog']['application_key'] = cmd.stdout.strip
  end
  action :run
end

node.default['datadog']['hostname'] = node.run_state['hostname']

include_recipe 'datadog::dd-agent'

cookbook_file '/etc/datadog-agent/conf.d/process.d/conf.yaml' do
  source 'process.d_conf.yaml'
  mode '0755'
  owner 'dd-agent'
  notifies :restart, 'service[datadog-agent]', :delayed
end
