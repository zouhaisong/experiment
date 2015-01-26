require 'active_support/all'

require 'rbvmomi'


vcenter_host    = ENV['VCENTER_HOST']
datacenter_name = ENV['DATACENTER_NAME']
username        = ENV['USERNAME']
password        = ENV['PASSWORD']

def log(message)
  puts message
end
def id_of_counter(counter)
  "#{counter.groupInfo.key}.#{counter.nameInfo.key}.#{counter.rollupType}"
end

@vim = RbVmomi::VIM.connect :host => vcenter_host, :port => 443, :user => username, :password => password, :insecure => true
@dc = @vim.serviceInstance.find_datacenter(datacenter_name) or fail "datacenter not found"


#--------------------------------------------------------------------------
vm = @dc.find_vm("scaleworks02")
vm.summary.quickStats
vm.config.hardware.memoryMB
