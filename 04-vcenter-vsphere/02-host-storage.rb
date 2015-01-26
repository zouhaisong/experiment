#!/usr/bin/env ruby

# Q: host storage associations capability
#TODO A: host-storage has only connected or not connected status, no accessible status

require 'logger'
require "pp"
require 'open-uri'

require 'active_support/all'
require 'fileutils'
require 'uuidtools'

require 'rbvmomi'

require 'dotenv'
Dotenv.load(".env", ".env.default", "~/.env")

vcenter_host    = ENV['VCENTER_HOST']
datacenter_name = ENV['DATACENTER_NAME']
username        = ENV['USERNAME']
password        = ENV['PASSWORD']

def logger
  return @logger if @logger

  @logger = Logger.new(STDOUT)
  @logger.level = Logger::DEBUG
  @logger
end
################################################################################

vim = RbVmomi::VIM.connect :host => vcenter_host, :port => 443, :user => username, :password => password, :insecure => true
logger.info("Connect to #{vcenter_host} success.")


dc = vim.serviceInstance.find_datacenter(datacenter_name)

logger.info dc.datastore.map{|i| i.name}

datastore = dc.datastore.find{|i| i.name=='NFS_Mount'}
datastore.host
#RbVmomi::VIM::DatastoreHostMount
