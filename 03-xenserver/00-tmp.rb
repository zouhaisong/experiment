#!/usr/bin/env ruby
require 'active_support/all'
require "pp"
require 'fileutils'
require 'uuidtools'
require 'open-uri'
require 'dotenv'
require 'fog/xenserver'


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
vm = compute.servers.get_by_uuid("1fa5c9bc-69e3-a787-3d04-f413216c2d54")
one_G = 1.gigabytes.to_i.to_s
vm.set_memory_limits(one_G,one_G,one_G,one_G)
################################################################################

