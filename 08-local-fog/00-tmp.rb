#!/usr/bin/env ruby
require 'fileutils'
require 'fog'
require 'uuidtools'

compute = Fog::Compute.new({
  :provider => "vsphere",
  "vsphere_username" => ENV['USERNAME'],
  "vsphere_password" => ENV['PASSWORD'],
  "vsphere_server" => ENV['VCENTER_HOST'],
  "vsphere_ssl" => true,
  "vsphere_expected_pubkey_hash" => ENV['PUBKEY_HASH']
})

setting = {:datacenter => "NewDatacenter"}
vms = compute.list_virtual_machines(setting)
vm = vms.find{|vm| vm["name"] =~ /MY_VM_NAME/}
compute.vm_snapshot_create('instance_uuid'=>vm.config.instanceUuid, 'name'=>"SNAPSHOT_NAME",'memory'=>false)

