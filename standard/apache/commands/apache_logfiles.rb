contributes_to :find_logs

param :machine

add_columns [ :service, :path, :source, :format, :parser ]

on_machine do |machine, params|
  result = []
  
  services = machine.list_services
  all_vhosts = machine.list_configured_vhosts
  
  if services.pick('name').include? 'apache'
    services.each do |service|
      next unless service.has_key?('domain') && service['domain']
      domain = service["domain"]
      next unless domain
      if domain.is_a? Array
        domain = domain.first if domain.first
      end
      domain.chomp!

      vhosts = all_vhosts.select { |x| x['domain'].chomp == domain.chomp }
      vhosts.each do |vhost|
        all_vhosts.delete vhost
        
        if vhost.has_key?("log_path")
          h = {
            "service" => service["full_name"],
            "path" => vhost["log_path"],
            "source" => "apache",
            "format" => vhost["log_format"]
          }
          result << h
        end
        
        if vhost.has_key?("error_log_path")
          result << {
            "service" => service["full_name"],
            "path" => vhost["error_log_path"],
            "source" => "apache",
            "format" => vhost["error_log_format"]
          }
        end
        
      end
    end
  end
  
  all_vhosts.each do |vhost|
    if vhost.has_key? "log_path"
      result << {
        "service" => "apache/apache",
        "path" => vhost["log_path"],
        "source" => "apache",
        "format" => vhost["log_format"]
      }
    end
  end
  
  result.each do |entry|
    entry["parser"] = "xop_apache" if entry["source"] == "apache" and entry["format"] == "vop"
  end
  
  result
end
