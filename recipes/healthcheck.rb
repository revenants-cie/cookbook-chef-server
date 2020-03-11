package 'xinetd'

cookbook_file "/etc/xinetd.d/echo" do
    source 'xinetd.echo'
    mode '0600'
    owner 0
    group 0
    notifies :restart, 'service[xinetd]', :delayed
end

service 'xinetd'

