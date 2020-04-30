#
# Cookbook:: chef-server
# Recipe:: default
#
# Copyright:: 2019, Revenants CIE, LLC, All Rights Reserved.
# As per https://docs.chef.io/install_server.html
# Chef Software requirements
# https://docs.chef.io/install_server_pre.html#software-requirements

hostname "chef-server.#{node['certbot']['zones'][0]}"
include_recipe "chef-server::environment"
include_recipe 'chef-server::awscli'
include_recipe "chef-server::aws_config"
include_recipe "chef-server::artifactory_credentials"
include_recipe "chef-server::repos"
include_recipe "chef-server::packages"
include_recipe "chef-server::chef-license"
include_recipe "chef-server::cookbook"
include_recipe "chef-server::chef-backup"
include_recipe "chef-server::chef-restore"
include_recipe "chef-server::certbot"
include_recipe "chef-server::users"
include_recipe "chef-server::chef-server"
include_recipe "chef-server::mail-relay"
include_recipe "chef-server::chef-solo"
include_recipe "chef-server::chef-cleanup"
include_recipe "chef-server::healthcheck"
include_recipe 'chef-server::datadog'
