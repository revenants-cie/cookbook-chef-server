#
# Cookbook:: chef-server
# Recipe:: default
#
# Copyright:: 2019, Revenants CIE, LLC, All Rights Reserved.
# As per https://docs.chef.io/install_server.html
# Chef Software requirements
# https://docs.chef.io/install_server_pre.html#software-requirements

include_recipe "chef-server::packages"
include_recipe "chef-server::certbot"
include_recipe "chef-server::chef-server"
include_recipe "chef-server::users"
include_recipe "chef-server::mail-relay"
include_recipe "chef-server::chef-solo"
include_recipe "chef-server::chef-backup"
