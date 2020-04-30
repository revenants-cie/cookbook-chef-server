# frozen_string_literal: true

ruby_block 'get_revdbio_artifactory_creds' do
  block do
    path = ENV['PATH'].split(':')
    path << '/usr/local/bin'
    ENV['PATH'] = path.uniq.join(':')
    ENV['HOME'] = '/root'
    secret_id = node['artifactory']['secret_id']
    cmd = Mixlib::ShellOut.new(
      'aws secretsmanager get-secret-value '\
      "--secret-id #{secret_id} "\
      '--output text --query SecretString'
    ).run_command
    Chef::Application.fatal!(cmd.stderr) unless cmd.exitstatus.zero?
    json_dict = JSON.parse(cmd.stdout)

    node.run_state['artifactory_user'] = json_dict['user']
    node.run_state['artifactory_api_key'] = json_dict['api_key']
  end
  action :run
end
