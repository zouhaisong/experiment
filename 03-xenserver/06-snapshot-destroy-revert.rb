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

node_name = "CentOS65-SS-test"
snapshot_name = "temp-snapshot"
node = @compute.servers.all.find{|vm| vm.name == node_name}
puts "Node : #{node} \t|\t #{node.uuid}"
puts '-'*40
snapshots = node.snapshots.map{|ref| @compute.servers.get(ref)}
Formatador.display_table(snapshots.map do |ss|
  {:name=>ss.name, :uuid=>ss.uuid, :snapshot_time=>ss.snapshot_time.to_time}
end)

# # Method 1: delete by name
# snapshot = node.snapshots.map{|ref| @compute.servers.get(ref)}.find{|ss| ss.name==snapshot_name}
# puts snapshot.allowed_operations
#
# snapshot.destroy
# # => true
#
# # Method 2: Get Snapshot by uuid
# ss1 = @compute.servers.get_by_uuid("3a4c3d52-9187-ecb2-8a61-2887d9702b11")
# ss1.destroy

# Revert VM to snapshot
ss = @compute.servers.get_by_uuid("3a4c3d52-9187-ecb2-8a61-2887d9702b11")
@compute.snapshot_revert(ss.reference)
# +--------------------+-------------------------+--------------------------------------+                                                                                                         [132/1896]
# | name               | snapshot_time           | uuid                                 |
# +--------------------+-------------------------+--------------------------------------+
# | centos65-ss-test-2 | 2015-01-22 06:57:59 UTC | ebbd4911-6b6d-a26e-b827-84a3682f8ca9 |
# +--------------------+-------------------------+--------------------------------------+
# | cemtps54-ss-test-1 | 2015-01-22 06:53:29 UTC | ad18abf9-cdec-44da-f38b-a05104f3ffda |
# +--------------------+-------------------------+--------------------------------------+
