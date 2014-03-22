description "prepares a powerdns instance to host a domain"

param :machine

param "domain", "if specified, the nameserver is preconfigured for the specified domain"
param "ip", "if specified, a set of A and PTR records will be created for the domain and IP"

on_machine do |machine, params|
  machine.domain_base_records("domain" => params["domain"])
    
  if params['ip']
    machine.add_domain_record(
      'domain' => params["domain"],
      'name' => params['domain'],
      'type' => 'A',
      'content' => params['ip']      
    )
    
    ip_parts = params['ip'].split('.')
    reverse_zone = ip_parts[0..2].reverse.join('.') + '.in-addr.arpa'
    machine.domain_base_records('domain' => reverse_zone)
    
    machine.add_domain_record(
      'domain' => reverse_zone,
      'name' => ip_parts.reverse.join('.') + '.in-addr.arpa',
      'type' => 'PTR',
      'content' => params['domain'] 
    )
  end
end
