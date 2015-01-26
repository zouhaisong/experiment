require 'active_support/all'

require 'rbvmomi'


vcenter_host    = ENV['VCENTER_HOST']
datacenter_name = ENV['DATACENTER_NAME']
username        = ENV['USERNAME']
password        = ENV['PASSWORD']

def log(message)
  puts message
end
def id_of_counter(counter)
  "#{counter.groupInfo.key}_#{counter.nameInfo.key}_#{counter.rollupType}"
end

@vim = RbVmomi::VIM.connect :host => vcenter_host, :port => 443, :user => username, :password => password, :insecure => true
@dc = @vim.serviceInstance.find_datacenter(datacenter_name) or fail "datacenter not found"
@perfManager = @vim.serviceInstance.content.perfManager

counters = @perfManager.perfCounter
@counter_id_map = Hash[counters.map{|i| [id_of_counter(i),i]}]
@counter_id_key_map = Hash[counters.map{|i| [id_of_counter(i),i.key]}]
@counter_key_map = Hash[counters.map{|i| [i.key,i]}]

@interval = 300 # one data per day
# @interval = 20 # instance


#--------------------------------------------------------------------------
# counter_ids = %w[
#         cpu_usage_average
#         cpu_usagemhz_average
#         cpu_ready_summation
#         mem_usage_average
#         mem_swapout_average
#         mem_active_average
#         disk_usage_average
#         disk_maxTotalLatency_latest
#         net_usage_average
#       ]
counter_ids = %w[mem_active_average]
vm = @dc.find_vm("ShunFeng_Ubuntu_Showcase_server_(WuJiafeng)_9_248")
entities = [vm]
vm = @dc.find_vm("PWC-SureSync Server_10.18.8.120")

# if entities.blank?
#   log {:size=>0, :data=>{}}.to_json
# end

counter_keys = counter_ids.map{|id| @counter_id_key_map[id]}
metrics = counter_keys.map{|ck| RbVmomi::VIM::PerfMetricId.new(:counterId=>ck, :instance=>"", :dynamicProperty=>[]) }
data = @perfManager.QueryPerf({:querySpec=>entities.map{|entity| {:entity=>entity,:intervalId=>@interval,:maxSample=>1,:metricId=>metrics} } })

# data.first.value.map{|i| i.id.counterId}
# data.first.sampleInfo.each{|i| puts i.timestamp} && nil
# data.first.value.each{|i| puts i.inspect} && nil


    def parse_pem(pem)
      # cloud_id = pem.entity.config.instanceUuid
      cloud_id = pem.entity.name
      metrics_values = Hash[pem.value.map{|pms| [@counter_id_key_map.key(pms.id.counterId),pms.value.last] }]

      [cloud_id, metrics_values]
    end

data = @perfManager.QueryPerf({:querySpec=>entities.map{|entity| {:entity=>entity,:intervalId=>20, :maxSample=>1,:metricId=>metrics} } })
data = @perfManager.QueryPerf({:querySpec=>entities.map{|entity| {:entity=>entity,:intervalId=>20, :maxSample=>1} } })

    entities_metric_values = Hash[data.map{|pem| parse_pem(pem) }]

    entities_metric_values.each do |name,values|
      puts '-'*80
      puts "Entity name: #{name}"
      puts values.map{|k,v| "--\t#{k}\t:\t#{v}"}
      puts "Total: #{values.size} metrics"
    end


