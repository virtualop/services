contributes_to :post_process_service_installation

param :machine
param :service, "", :default_param => true

accept_extra_params

on_machine do |machine, params|
  service = @op.service_details(params)
  
  if service.has_key?("apache_config")
    unless params.has_key?("extra_params") and params["extra_params"].has_key?("domain")
      raise "apache_config found for service #{service["name"]}, but no domain parameter is present. don't know where to publish, please give me a domain param"
    end
    
    domain = params["extra_params"]["domain"]
    if domain.is_a?(Array)
      domain = domain.first
    end      
    machine.install_canned_service("service" => "apache/apache")
    
    template_name = service["apache_config"]
    template_path = descriptor_dir + '/templates/' + template_name.to_s + '.erb'
    puts "template for apache config : #{template_path}"
    
    config_path = "#{machine.apache_generated_conf_dir}/#{domain}.conf"
    puts "apache config will be written into #{config_path}"
    
    generated = @op.with_machine(params["descriptor_machine"]) do |descriptor_machine|
      descriptor_machine.process_file(
        "file_name" => template_path,
        "bindings" => binding() 
      )
    end
    puts "generated : #{generated}"
    machine.as_user('root') do |root|
      root.write_file("target_filename" => config_path, "content" => generated)
    end
    
    machine.restart_service 'apache/apache'
    machine.configure_reverse_proxy("domain" => domain) if machine.proxy
  end
end