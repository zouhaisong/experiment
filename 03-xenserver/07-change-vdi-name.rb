#!/usr/bin/env ruby
require 'active_support/all'
require "pp"
require 'fileutils'
require 'fog'
require 'uuidtools'
require 'open-uri'
require 'formatador'

require 'dotenv'
Dotenv.load(".env", ".env.default", "~/.env")

xs_host = ENV['XS_HOST']
xs_user = ENV['XS_USER']
xs_password = ENV['XS_PASSWORD']

@compute = Fog::Compute.new({
  :provider => 'XenServer',
  :xenserver_url => xs_host,
  :xenserver_username => xs_user,
  :xenserver_password => xs_password,
  })

################################################################################
vm_name = "ci-202-2015-01-26_17-49-55"
vm = @compute.servers.find{|s| s.name==vm_name}
vm.vbds.find_all{|vbd| vbd.type == "Disk"}.map(&:vdi).map(&:name)
vdis = vm.vbds.find_all{|vbd| vbd.type == "Disk"}.map(&:vdi)
vdis.each_with_index do |vdi, index|
  vdi.set_attribute("name_label", "#{vm_name}.#{index}")
end
