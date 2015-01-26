#!/usr/bin/env ruby
require 'logger'
require "pp"
require 'open-uri'

require 'active_support/all'
require 'fileutils'
require 'uuidtools'

require 'rbvmomi'

require 'dotenv'
Dotenv.load(".env", ".env.default", "~/.env")

vcenter_host    = ENV['VCENTER_HOST']
datacenter_name = ENV['DATACENTER_NAME']
username        = ENV['USERNAME']
password        = ENV['PASSWORD']

def logger
  return @logger if @logger

  @logger = Logger.new(STDOUT)
  @logger.level = Logger::DEBUG
  @logger
end
################################################################################

vim = RbVmomi::VIM.connect :host => vcenter_host, :port => 443, :user => username, :password => password, :insecure => true

dc = vim.serviceInstance.find_datacenter(datacenter_name) or fail "datacenter not found"
perfManager = vim.serviceInstance.content.perfManager

columns = %w[key name_label name_summary name_key group_label group_summary group_key
  unit_label unit_summary unit_key rollup_type stats_type level]

rows = perfManager.perfCounter.map{|i|
  { key:i.key,
    name_label:i.nameInfo.label, name_summary:i.nameInfo.summary, name_key:i.nameInfo.key,
    group_label:i.groupInfo.label, group_summary:i.groupInfo.summary, group_key:i.groupInfo.key,
    unit_label:i.unitInfo.label, unit_summary:i.unitInfo.summary, unit_key:i.unitInfo.key,
    rollup_type:i.rollupType,stats_type:i.statsType, level:i.level
  }.with_indifferent_access
}

puts "*** Get #{rows.size} lines"

require 'axlsx'

Axlsx::Package.new do |p|
  p.workbook.add_worksheet(:name => "performance-couter") do |sheet|
    style_header = sheet.styles.add_style :bg_color => "12335d", :fg_color => "FF", :sz => 14, :alignment => { :horizontal=> :center }
    sheet.add_row columns, :style=>style_header
    rows.each do |row|
      puts row
      sheet.add_row columns.map{|key| row[key].to_s}, :style => Axlsx::STYLE_THIN_BORDER
    end
    # sheet.column_widths *keys.collect{|key| params[:columns][key][:column_width].to_i/10 }
  end
  p.serialize('performance-counter.xlsx')
end
