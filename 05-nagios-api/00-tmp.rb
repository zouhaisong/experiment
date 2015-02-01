#!/usr/bin/env ruby
require 'active_support/all'
require "pp"
require 'fileutils'
require 'open-uri'
require 'net/http'
require 'ostruct'

require 'dotenv'
Dotenv.load(".env", ".env.default", "~/.env")

################################################################################
# base_url = "http://10.18.10.2:8080/nagios/jsonquery.html"
require 'net/http'
base_url = "http://10.18.10.2:8080/nagios/cgi-bin/"
commandlist_path = "objectjson.cgi?query=commandlist"
uri = URI("#{base_url}#{commandlist_path}")

http = Net::HTTP.new(uri.host, uri.port)

request = Net::HTTP::Get.new uri.request_uri
request.basic_auth 'nagiosadmin', ''

response = http.request request # Net::HTTPResponse object

puts '-'*80
puts response.class
puts '-'*80
puts response.body

resp_json = JSON.parse(response.body)
puts resp_json
resp_json["data"]["commandlist"]
