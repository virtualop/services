description "removes a domain from the reverse proxy configured for this machine"

param :machine
param! 'domain', 'the domain for which the configuration should be cleaned up', :allows_multiple_values => true

param "restart", "set to true to restart the proxy to apply the configuration immediately",
  :lookup_method => lambda { %w|true false| }, :default_value => 'true'

on_machine do |machine, params|
  proxy_name = params["proxy"] || machine.proxy
  
  @op.with_machine(proxy_name) do |proxy|
    params['domain'].each do |domain|
      proxy.delete_vhost_configuration('domain' => domain)
      proxy.restart_service('apache/apache') if params['restart'].to_s == 'true'
    end
  end
end
