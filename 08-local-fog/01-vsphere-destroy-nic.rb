#!/usr/bin/env ruby
require 'fileutils'
require 'fog'
require 'uuidtools'

require 'dotenv'
Dotenv.load(".env", ".env.default", "~/.env")

compute = Fog::Compute.new({
  :provider => "vsphere",
  "vsphere_username" => ENV['USERNAME'],
  "vsphere_password" => ENV['PASSWORD'],
  "vsphere_server" => ENV['VCENTER_HOST'],
  "vsphere_ssl" => true,
  "vsphere_expected_pubkey_hash" => ENV['PUBKEY_HASH']
})


setting = {:datacenter => "NewDatacenter"}
compute.list_host_systems(setting)


vms = compute.list_virtual_machines(setting)

vm = vms.find{|vm| vm["name"] =~ /packer/}

nics = compute.list_nics("instance_uuid"=>vm["id"])

nics.map{|n| {:key=> n.key, :label=> n.deviceInfo.label} }

compute.vm_destroy_nic({"instance_uuid"=>vm['id'], "nic_key"=>4001})

vm_ref = vm["vm_mob_ref"].call
puts vm_ref.config.hardware.device.map{|n| {:key=> n.key, :label=> n.deviceInfo.label}}
nic = vm_ref.config.hardware.device.find{|d| d.key == 4001 && d.is_a?(RbVmomi::VIM::VirtualEthernetCard)}