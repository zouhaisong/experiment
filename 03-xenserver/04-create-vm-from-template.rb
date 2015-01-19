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
image_name = "CentOS65-H710-V06"
vm_name = "temp-#{Time.now.to_i}"

def compute
  @compute
end

def list_images
  compute.servers.custom_templates
end

attributes = %w[name is_a_template is_a_snapshot is_control_domain uuid]
  # is_snapshot_from_vmpp snapshot_info snapshot_metadata ]

Formatador.display_table list_images.map{|i| Hash[attributes.map{|a| [a,i.send(a)] }] }

vm = compute.servers.new :name => vm_name, :template_name => "e9016941-1db5-f931-4760-625d011db6c4"
vm.save

def list_snapshots
  compute.servers.custom_templates.find_all{|t| t.is_a_snapshot }
end

def list_templates
  compute.servers.custom_templates.find_all{|t| t.is_a_template && !t.is_a_snapshot }
end
snapshot = "temp-snapshot"
template_name = "template-#{snapshot}"
def convert_snapshot_to_template(snapshot,template_name)
  if snapshot.is_a?(String)
    snapshot = list_snapshots.find{|s| s.name==snapshot}
  end


  # # Fail 1
  # snapshot.is_a_snapshot = false
  # snapshot.save

  snapshot.is_a_snapshot = false


  # # Fail 2 VM.create_template
  # compute.instance_eval{
  #   @connection.request({
  #       :parser => Fog::Parsers::XenServer::Base.new,
  #       :method => 'VM.create_template'
  #     },
  #     snapshot.reference
  #   )
  # }
  # # Fail 3 VM.make_into_template
  # compute.instance_eval{
  #   @connection.request({
  #       :parser => Fog::Parsers::XenServer::Base.new,
  #       :method => 'VM.make_into_template'
  #     },
  #     snapshot.reference
  #   )
  # }

  compute.instance_eval{
    @connection.request({
        :parser => Fog::Parsers::XenServer::Base.new,
        :method => 'VM.clone'
      },
      snapshot.reference,
      template_name
    )
  }
end
convert_snapshot_to_template(snapshot,template_name)

# ximage = list_images.find{|i| i.name==image_name}
# puts "Use Image: #{ximage.name}"
# vm = compute.servers.new :name => vm_name, :template_name => ximage.uuid
# vm.save


