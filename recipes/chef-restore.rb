%w(restore_certificates restore_chef_server).each { |tool|
    cookbook_file "/usr/local/bin/#{tool}.sh" do
        source "#{tool}.sh"
        mode '0755'
        owner 'root'
        group 'root'
    end
}

execute 'restore_certificates' do
    command "/usr/local/bin/restore_certificates.sh"
    not_if { File.directory?('/etc/letsencrypt') }
    action :run
end
