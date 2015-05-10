require "bunny"

puts Bunny::VERSION

puts "receiver"

conn = Bunny.new(:automatically_recover => false)
conn.start

ch   = conn.create_channel
q    = ch.queue("benny2", :durable => true)
ch.prefetch(1)
begin
  puts " [*] Waiting for messages. To exit press CTRL+C"
  q.subscribe(:manual_ack => true, :block => true) do |delivery_info, properties, body|
    # puts delivery_info
    sleep 0.5
    puts " [x] Received #{body}"
    ch.ack(delivery_info.delivery_tag)
  end
rescue Interrupt => _
  conn.close

  exit(0)
end