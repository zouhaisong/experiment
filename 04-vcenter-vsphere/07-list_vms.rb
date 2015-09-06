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
vms = vim.serviceContent.viewManager.CreateContainerView({
  :container  => dc.vmFolder,
  :type       =>  ["VirtualMachine"],
  :recursive  => true
  }).view
vm_names = vms.map{|vm| vm.name}
vm_names.detect{|e| vm_names.count(e) > 1 }
vms.find_all{|vm| vm.name=='SifyVDP01'}

ids = ["50028e0c-39d7-038b-a03f-f6b1934a8154",
  "50025c66-ce47-8e99-3f1c-c1570405c248",
  "500248eb-cafa-c476-dc4a-14527d9a195c",
  "50021bad-834a-d469-af1a-824a4bb6bb16",
  "500236a7-4fd7-7c67-7f08-dd58e3b8046e",
  "5002b110-682d-cdc0-f230-31d061605859",
  "50029542-4346-22da-490c-0fd78516a306",
  "5002b2eb-a0ee-a7cb-8ae8-735f62f98800",
  "50024c97-e3e6-4879-886b-5af39bad5dba"]
vms1 = ids.map{|vm_id|
  params = {:uuid => vm_id, :vmSearch => true, :instanceUuid => true}
                params[:datacenter] = dc
  vim.searchIndex.FindByUuid(params)
}
vms1.map(&:name)
# => ["OSCI01", "psoradb01", "psoradb01_clone", "bahmni_108838_01", "bahmni_108838_02",
# "JT_Win7_108377", "agupta05", "sify-kstest01", "BalaSwecha02-109360"]
