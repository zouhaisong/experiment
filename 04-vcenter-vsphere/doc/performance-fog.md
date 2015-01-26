cloud_system = CloudSystem.new(:name=>"vsphere",:provider=>"vsphere",
  :setting => {"compute"=>{"provider"=>"vsphere","vsphere_username"=>"corporate\\scaleworks","vsphere_password"=>"Welc0me@tw123","vsphere_server"=>"sifyvcenter.corporate.thoughtworks.com","vsphere_ssl"=>true,"vsphere_expected_pubkey_hash"=>"fe3ca4dbce63cd5dad17f0d9467d4db6051cf7c57b4a4ece90db199485af4caa"},"datacenter"=>"Corporate"}.to_json
)

VsphereQueryPerf.new.hosts_data(cloud_system)

