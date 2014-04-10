description "adds a virtual host for static files to the apache configuration"

param :machine

param! "server_name", "the http domain served by this vhost", :allows_multiple_values => true
param! "document_root", "fully qualified path to the directory holding the static files"
param "twist", "some extra content that should be included in the Directory section of the generated config"
param "erb_twist", "like +twist+, but gets erb processed (probably not a good idea (tm))"

as_root do |machine, params|
  generated_dir = machine.apache_generated_conf_dir
  
  # TODO handle other domains
  first_domain = params["server_name"].first
  
  directory_includes = ''
  vhost_includes = ''
  
  if params['twist']
    vhost_includes = params["twist"]  
  elsif params['erb_twist']
    vhost_includes = output = ERB.new(params["erb_twist"]).result(binding())
  end
  
  process_local_template(:apache_static_vhost, machine, "#{generated_dir}/#{first_domain}.conf", binding())
  
  # TODO make sure the document root has the appropriate permissions (apache/www-data)
  
  @op.without_cache do
    machine.list_configured_vhosts
  end
end
