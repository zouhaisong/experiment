#!/usr/bin/env ruby
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

dc = vim.serviceInstance.find_datacenter(datacenter_name) or fail "datacenter not found"

vm = dc.find_vm("tli-packer")
nics = vm.config.hardware.device.find_all{|d| d.is_a?(RbVmomi::VIM::VirtualEthernetCard)}

# vim.searchIndex.FindByUuid :uuid=>vm.config.instanceUuid, :vmSearch => true, :instanceUuid => true
# dc.find_vm vm.name
#
#
# image = dc.vmFolder.traverse "demo-to-delete06"