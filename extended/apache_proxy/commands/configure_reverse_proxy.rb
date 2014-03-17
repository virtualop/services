description 'configures a reverse proxy virtualop host on the proxy machine sitting on the same host as the selected machine'

param :machine
param! "domain", "the domain at which the service should be available", :allows_multiple_values => true
param "timeout", "configuration for the ProxyTimeout directice - timeout in seconds to wait for a proxied response"
param "proxy", "name of the machine where the proxy is running"
param "port", "a port to forward to (defaults to 80)"
param "restart", "set to true to restart the proxy to apply the configuration immediately",
  :lookup_method => lambda { %w|true false| }, :default_value => 'true'
param "without_reload"

on_machine do |machine, params|
  
  proxy_name = params["proxy"] || machine.proxy
  
  @op.with_machine(proxy_name) do |proxy|
    port = params.has_key?("port") ? ':' + params["port"] : ''
    p = {
      "server_name" => params["domain"], 
      "target_url" => "http://#{machine.ipaddress}#{port}/",
      'without_reload' => true
    }.merge_from params, :timeout, :without_reload
    proxy.add_reverse_proxy(p)

    if params['restart'].to_s == 'true'    
      services = proxy.list_installed_services
      service_name = nil
      # TODO snafu
      if services.include?('apache/apache')
        service_name = 'apache/apache'
      elsif services.include? 'apache'
        service_name = 'apache'
      end
      proxy.restart_service(service_name) if service_name
    end
  end
end