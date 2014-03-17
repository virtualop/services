contributes_to :post_process_service_installation

param :machine
param :service, "", :default_param => true

accept_extra_params

on_machine do |machine, params|
  service = @op.service_details(params)
  
  if service.has_key?("static_html")
    unless params.has_key?("extra_params") and params["extra_params"].has_key?("domain")
      raise "static_html configuration found for service #{service["name"]}, but no domain parameter is present. don't know where to publish static html pages"
    end
    
    domain = params["extra_params"]["domain"]
    machine.install_canned_service("service" => "apache/apache")

    vhost_options = {
      "server_name" => domain, 
      "document_root" => service["service_root"]
    }
    options = service["static_html"]
    if options.is_a?(Hash)
      [ 'twist', 'document_root' ].each do |key|
        if options.has_key?(key)
          vhost_options[key] = options[key]
        end
      end
    end
    machine.add_static_vhost(vhost_options)
    machine.allow_access_for_apache("file_name" => vhost_options['document_root'])
    machine.restart_service 'apache/apache'
    # TODO this does not update old entries
    unless machine.list_domains_pointing_to_machine.include? domain
      machine.configure_reverse_proxy("domain" => domain)
    end
  end
end
