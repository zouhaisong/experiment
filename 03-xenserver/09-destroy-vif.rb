#!/usr/bin/env ruby
require 'active_support/all'
require "pp"
require 'fileutils'
require 'fog'
require 'uuidtools'
require 'open-uri'

require 'dotenv'
Dotenv.load(".env", ".env.default", "~/.env")

xs_host = ENV['XS_HOST']
xs_user = ENV['XS_USER']
xs_password = ENV['XS_PASSWORD']

compute = Fog::Compute.new({
  :provider => 'XenServer',
  :xenserver_url => xs_host,
  :xenserver_username => xs_user,
  :xenserver_password => xs_password,
})

puts "Connected to #{xs_host}."


vm = compute.servers.find{|vm| vm.name=='hszou-test-0302'}
puts vm.vifs.map{|vif| vif.to_json}

vif = vm.vifs.find{|vif| vif.device == '1'}


if vif.allowed_operations.include?("unplug")
  compute.instance_eval{
    @connection.request({
      :parser => Fog::Parsers::XenServer::Base.new,
      :method => 'VIF.unplug'
    },
    vif.reference
    )
  }
end
vif.destroy
