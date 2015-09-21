#!/usr/bin/env ruby
require 'formatador'
require 'dotenv'
require 'docker'

Dotenv.load(".env", ".env.default", "~/.env")

cert_path = ENV["DOCKER_CERT_PATH_01"]
conn01 = Docker::Connection.new(ENV["DOCKER_HOST_01"], {
  client_cert: File.join(cert_path, 'cert.pem'),
  client_key: File.join(cert_path, 'key.pem'),
  ssl_ca_file: File.join(cert_path, 'ca.pem'),
  scheme: 'https'
})

images = JSON.parse(conn01.get('/images/json'))
Formatador.display_table(images)

images = Docker::Image.all({},conn01)

cert_path = ENV["DOCKER_CERT_PATH_02"]
conn02 = Docker::Connection.new(ENV["DOCKER_HOST_02"], {
  client_cert: File.join(cert_path, 'cert.pem'),
  client_key: File.join(cert_path, 'key.pem'),
  ssl_ca_file: File.join(cert_path, 'ca.pem'),
  scheme: 'https'
})
Formatador.display_table(JSON.parse(conn02.get('/images/json')))
Formatador.display_table(JSON.parse(conn02.get('/containers/json')))




# This Does NOT work
# puts Docker.url
# puts Docker.version
# puts Docker.info
# puts Docker::Image.all

# Excon
response = Excon.get("#{Docker.url}/info".sub("tcp","https"),Docker.options)
response.body       # => "..."
response.headers    # => {...}
response.remote_ip  # => "..."
response.status     # => 200

