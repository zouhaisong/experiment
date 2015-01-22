
class MigrateImageFromSnapshotToTemplate
  def list_snapshots(compute)
    compute.servers.custom_templates.find_all{|t| t.is_a_snapshot }
  end

  def list_templates(compute)
    compute.servers.custom_templates.find_all{|t| t.is_a_template && !t.is_a_snapshot }
  end

  def convert_snapshot_to_template(compute, snapshot, template_name)
    compute.instance_eval{
      @connection.request({
        :parser => Fog::Parsers::XenServer::Base.new,
        :method => 'VM.clone'
      },
      snapshot.reference,
      template_name
      )
    }
  end

  def migrate_all_image(compute)
    snapshots = list_snapshots(compute)
    templates = list_templates(compute)
    snapshots_names = snapshots.map{|ss| ss.name }
    templates_names = templates.map{|t| t.name }
    snapshots.each do |ss|
      if !ss.name.in?(templates_names)
        puts "Convert Snapshot [#{ss.name}] to Template "
        convert_snapshot_to_template(compute, ss, ss.name)
      else
        puts "Template [#{ss.name}], Skiped"
      end
    end
  end

  def get_compute(cloud_system)
    _compute = Fog::Compute.new({
      :provider           => 'XenServer',
      :xenserver_url      => cloud_system.setting_object["compute"]["xenserver_url"],
      :xenserver_username => cloud_system.setting_object["compute"]["xenserver_username"],
      :xenserver_password => cloud_system.setting_object["compute"]["xenserver_password"],
      :xenserver_timeout  => 60
      })
    return _compute
  end

  def run
    CloudSystem.where(:provider=>'xen_server').each do |cs|
      puts "Migrate #{cs.setting_object["compute"]["xenserver_url"]}"
      compute = get_compute(cs)
      migrate_all_image(compute)
    end
    "== DONE =="
  end
end
MigrateImageFromSnapshotToTemplate.new.run