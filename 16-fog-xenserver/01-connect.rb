#!/usr/bin/env ruby
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

puts "#{compute.servers}"

s = compute.servers.find{|s| s.name=='test-343'}

compute.instance_eval{
  @connection.request({
    :parser => Fog::Parsers::XenServer::Base.new,
    :method => "VM.set_name_label" }, s.reference, "test-343-changed")
}
