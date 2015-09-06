require 'fileutils'
require 'fog'
require 'uuidtools'

def ssh_options password = nil
  options = {:port => 22, :keys => ["~/.ssh/id_rsa"]}
  options[:password] = password if password
  options[:auth_methods] = ['publickey','password']
  options[:number_of_password_prompts] = 0
  options
end

host = ENV["VM_HOST_IP"]
username = ENV["VM_HOST_USERNAME"]

blk = lambda{|data| data}
ret = Fog::SSH.new(host, username, ssh_options).run(commands, &blk)

