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
      rollup_type:i.rollupType,stats_type:i.statsType
    }.with_indifferent_access
  end

  def main
    vcenter_host    = ENV['VCENTER_HOST']
    datacenter_name = ENV['DATACENTER_NAME']
    username        = ENV['USERNAME']
    password        = ENV['PASSWORD']
    vim = RbVmomi::VIM.connect :host => vcenter_host, :port => 443, :user => username, :password => password, :insecure => true
    dc = vim.serviceInstance.find_datacenter(datacenter_name) or fail "datacenter not found"
    perfManager = vim.serviceInstance.content.perfManager

    host = dc.hostFolder.childEntity.map(&:host).flatten.find{|h| h.name=='10.18.1.103'}
    hosts = [host]

counters = perfManager.perfCounter.select{|i| i.groupInfo.key.in?(%w[mem]) && i.nameInfo.key.in?(%w[usage granted active])}.map{|i| i.key }

# 可用的统计指标
# perfManager.QueryAvailablePerfMetric({:entity=>host}).map{|i| "#{i.counterId}-#{i.instance}"}
metrics = perfManager.QueryAvailablePerfMetric({:entity=>host}).select{|i| i.counterId.in?(counters)}

# interval = perfManager.historicalInterval.find{|i| i.name=="Past day"}

    # data = perfManager.QueryPerf({:querySpec=>hosts.map{|i| {:entity=>i}}})
    data = perfManager.QueryPerf({:querySpec=>hosts.map{|i| {:entity=>i,:intervalId=>7200,:metricId=>metrics}}})
# 取到的数据的counterId
# data.first.value.map{|i| i.id.counterId}
# data.first.sampleInfo.each{|i| puts i.inspect} && nil
# data.first.value.each{|i| puts i.inspect} && nil


    ## host的统计数据是否可用,刷新频率
    # perfManager.QueryPerfProviderSummary({:entity=>host})

    ## 可用的counter
    # perfManager.perfCounter.select{|i| i.groupInfo.key=='mem'}.map{|i| "#{i.groupInfo.key}.#{i.nameInfo.key}.#{i.rollupType}" }
perfManager.perfCounter.select{|i| i.groupInfo.key.in?(%w[mem]) && i.nameInfo.key.in?(%w[usage granted active])}.map{|i| i.key }

    ## host可以获取的Metric
    # perfManager.QueryAvailablePerfMetric({:entity=>host})

  end
end

if __FILE__ == $0
  r = RetrievePerformanceData.new
  r.main
end
