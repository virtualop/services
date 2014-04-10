description "adds a virtual host for static files to the apache configuration"

param :machine

param! "server_name", "the http domain served by this vhost", :allows_multiple_values => true
param! "document_root", "fully qualified path to the directory holding the static files"

param "twist", "extra content that should be included in the Directory section of the generated config"
param "erb_twist", "like +twist+, but gets erb processed (probably not a good idea (tm))"
param "twist_target", "can be used to add +twist+/+erb_twist+ into the VHost rather than the Directory section",
  :lookup_method => lambda { %w|vhost directory| }, :default_value => 'directory'

as_root do |machine, params|
  generated_dir = machine.apache_generated_conf_dir
  
  # TODO handle other domains
  first_domain = params["server_name"].first
  
  includes = {
    :vhost => '',
    :directory => ''
  }
  
  twist = nil
  if params['twist']
    twist = params["twist"]  
  elsif params['erb_twist']
    twist = ERB.new(params['erb_twist']).result(binding())
  end
  
  if twist
    includes[params['twist_target'].to_sym] = twist
  end
  
  process_local_template(:apache_static_vhost, machine, "#{generated_dir}/#{first_domain}.conf", binding())
  
  # TODO make sure the document root has the appropriate permissions (apache/www-data)
  
  @op.without_cache do
    machine.list_configured_vhosts
  end
end
