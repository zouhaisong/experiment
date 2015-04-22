require "bunny"

puts Bunny::VERSION

puts "sender"

conn = Bunny.new(:automatically_recover => false)
conn.start

ch   = conn.create_channel
q    = ch.queue("benny1")

(1..100).each do |i|
  ch.default_exchange.publish("Hello World! - #{100-i}", :routing_key => q.name)
  puts " [x] Sent 'Hello World!'#{100-i}"
  sleep 1.0
end

conn.close