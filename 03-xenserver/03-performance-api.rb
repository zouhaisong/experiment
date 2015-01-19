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

################################################################################

puts "Connected to #{xs_host}."
connection = compute.instance_eval{@connection}
# connection.request({:parser => Fog::Parsers::XenServer::Base.new, :method => 'host_rrd'})
# connection.request({:parser => Fog::Parsers::XenServer::Base.new, :method => 'get_host_rrd'}, vm_ref, false, false)
credentials = connection.instance_eval{@credentials}
# => "OpaqueRef:471fc296-2d9a-473e-8794-4fac52ce1b36"

################################################################################

a_month_ago = (Time.now-60*60*24*30).to_i
url = "http://#{xs_host}/host_rrd?session_id=#{credentials}"
# url = "http://#{xs_host}/rrd_updates?session_id=#{credentials}"
url << "&cf=AVERAGE&start=#{a_month_ago}&interval=#{60*60*24}&host=true"
response  = open(url) {|f| f.read }

example_file_name = "03-rrd.example.xml"

url = "http://#{xs_host}/vm_rrd?session_id=#{credentials}"
url << "&cf=AVERAGE&start=#{Time.now.to_i-10}&interval=86400&uuid=056ef46a-3cb9-626c-451a-a0fe05a1a4ab"
response  = open(url) {|f| f.read }
File.open(example_file_name,"w+"){|f| f.puts response}


# doc = Nokogiri.XML(open(example_file_name))

