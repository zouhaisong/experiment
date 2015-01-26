require 'active_support/all'

require 'rbvmomi'

class RetrievePerformanceData
  def save(obj,filename)
    File.open(filename,"w+"){|f|f.puts obj.inspect}
  end

  def flatten_counter(i)
    { key:i.key,
      name_label:i.nameInfo.label, name_summary:i.nameInfo.summary, name_key:i.nameInfo.key,
      group_label:i.groupInfo.label, group_summary:i.groupInfo.summary, group_key:i.groupInfo.key,
      unit_label:i.unitInfo.label, unit_summary:i.unitInfo.summary, unit_key:i.unitInfo.key,
      rollup_type:i.rollupType,stats_type:i.statsType, level:i.level
    }.with_indifferent_access
  end

  def log(message)
    puts message
  end
  def id_of_counter(counter)
    "#{counter.groupInfo.key}.#{counter.nameInfo.key}.#{counter.rollupType}"
  end
  def main
    vcenter_host    = ENV['VCENTER_HOST']
    datacenter_name = ENV['DATACENTER_NAME']
    username        = ENV['USERNAME']
    password        = ENV['PASSWORD']
    vim = RbVmomi::VIM.connect :host => vcenter_host, :port => 443, :user => username, :password => password, :insecure => true
    log("Connect to #{vcenter_host} success.")
    dc = vim.serviceInstance.find_datacenter(datacenter_name) or fail "datacenter not found"
    log("#{datacenter_name} ok.")

    hosts = dc.hostFolder.childEntity.map(&:host).flatten

    log("#{hosts.count} hosts found. #{hosts.map{|h| "#{h.to_s}:\t#{h.name}"}.join("\n-- ") }")
    log(hosts.map(&:_ref).to_json)
    perfManager = vim.serviceInstance.content.perfManager

    log("Available intervals:");
    log perfManager.historicalInterval.map{|i| i.inspect}.join("\n")

    counters = perfManager.perfCounter
    counter_id_map = Hash[counters.map{|i| [id_of_counter(i),i]}]
    counter_key_map = Hash[counters.map{|i| [i.key,i]}]

# 可用的统计指标, 根据counter id求metrics
    # counter_ids = %w[disk.usage.average mem.usage.average cpu.usage.average disk.capacity.latest]
    counter_ids = %w[cpu.usage.average cpu.usagemhz.average]
    entity = dc.find_vm("BJLUA01_10.18.1.26")

    metrics = perfManager.QueryAvailablePerfMetric({:entity=>entity}).select{|i|
      id_of_counter(counter_key_map[i.counterId]).in?(counter_ids)
    }.uniq{|m| m.counterId}

# interval = perfManager.historicalInterval.find{|i| i.name=="Past day"}
interval = 86400 # one data per day

    # data = perfManager.QueryPerf({:querySpec=>hosts.map{|i| {:entity=>i}}})
    data = perfManager.QueryPerf({:querySpec=>[{:entity=>entity,:intervalId=>interval,:metricId=>metrics}]})
# 取到的数据的counterId
# data.first.value.map{|i| i.id.counterId}
# data.first.sampleInfo.each{|i| puts i.timestamp} && nil
# data.first.value.each{|i| puts i.inspect} && nil


    ## host的统计数据是否可用,刷新频率
    # perfManager.QueryPerfProviderSummary({:entity=>host})

    ## 可用的counter
    # perfManager.perfCounter.select{|i| i.groupInfo.key=='mem'}.map{|i| "#{i.groupInfo.key}.#{i.nameInfo.key}.#{i.rollupType}" }
# perfManager.perfCounter.select{|i| i.groupInfo.key.in?(%w[mem]) && i.nameInfo.key.in?(%w[usage granted active])}.map{|i| i.key }

    ## host可以获取的Metric
    # perfManager.QueryAvailablePerfMetric({:entity=>host})

  end

  def retrieve_series(data, entity, counter)
    entity_pem = data.select{|pem| pem.entity == entity}
    pem.sampleInfo
  end
end

if __FILE__ == $0
  r = RetrievePerformanceData.new
  r.main
end
