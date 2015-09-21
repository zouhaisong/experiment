#!/usr/bin/env ruby
require 'formatador'
require 'dotenv'
require 'docker'

Dotenv.load(".env", ".env.default", "~/.env")

# authenticate!
# connection
# default_socket_url
# env_options
# env_url
# info
# options
# options=
# reset!
# reset_connection!
# url
# url=
# validate_version!
# version

puts Docker.url
puts Docker.version
puts Docker.info


# Excon
response = Excon.get("#{Docker.url}/info".sub("tcp","https"),Docker.options)
response.body       # => "..."
response.headers    # => {...}
response.remote_ip  # => "..."
response.status     # => 200

