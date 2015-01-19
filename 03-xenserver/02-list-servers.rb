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


def ipaddress(server)
  if server.guest_metrics
    ip = server.guest_metrics.networks["0/ip"] #.values.join(", ")
  else
    ip = ''
  end
  return ip
end

################################################################################

# compute.servers.custom_templates.map(&:name)
servers = compute.servers
puts servers.map{|s| "#{s.name} -> #{ipaddress(s)}" }.join("\n")


################################################################################

server = servers.find{|s| s.name =~ /Image-CentOS7-Live/i}
server.guest_metrics
puts ipaddress(server)

