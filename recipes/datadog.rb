ruby_block "get_datadog_api_key_from_asm" do
    block do
        ENV['HOME'] = '/root'
        cmd = Mixlib::ShellOut.new(
            "aws secretsmanager get-secret-value --secret-id #{node['datadog_api_key_secret_id']} --output text --query SecretString"
        ).run_command
        Chef::Application.fatal!(cmd.stderr) unless cmd.exitstatus == 0
        node.default['datadog']['api_key'] = cmd.stdout
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
