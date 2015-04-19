#!/usr/bin/env ruby
require 'fileutils'
require 'uuidtools'
require 'dotenv'
require 'docker'

Dotenv.load(".env", ".env.default", "~/.env")

Docker.url = 'tcp://127.0.0.1:2375/'
puts Docker.version
puts Docker.info
# response = Excon.get('http://localhost:2375/info')
# response.body       # => "..."
# response.headers    # => {...}
# response.remote_ip  # => "..."
# response.status     # => 200

