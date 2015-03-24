require 'net/scp'
require 'fileutils'

Net::SSH.start(ENV['HOST'], ENV['USERNAME'], :password => ENV['PASSWORD'], :verbose => :error) do |ssh|
  ssh.scp.upload!("/tmp/seed-e9f77878-3330-9752-f49f-1ddb7f21462d.iso", "/tmp")
end
