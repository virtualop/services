param :machine

param "domain", "if specified, the nameserver is preconfigured for the specified domain"
param "ip", "if specified, a set of A and PTR records will be created for the domain and IP"
param 'type', 'the type of domain to create', :default_value => ''

on_machine do |machine, params|
  machine.execute_sql("database" => "powerdns", "statement" => 
    (params['type'] != '') ?
      "insert into domains (name, type) values ('#{params["domain"]}', '#{params['type']}')" :
      "insert into domains (name) values ('#{params["domain"]}')
  ")
  data = mysql_xml_to_rhcp machine.execute_sql("database" => "powerdns", "xml" => "true", "statement" => 
    "select id from domains where name = '#{params["domain"]}'"
  )
  id = data.first["id"]
  
  [
    "insert into records (domain_id, name, type, content, ttl) values (#{id}, '#{params["domain"]}', 'SOA', 'localhost #{machine.name} 1', 86400)",
    "insert into records (domain_id, name, type, content, ttl) values (#{id}, '#{params["domain"]}', 'NS', 'ns1.#{params["domain"]}', 86400)",
    "insert into records (domain_id, name, type, content, ttl) values (#{id}, '#{params["domain"]}', 'NS', 'ns2.#{params["domain"]}', 86400)",
  ].each do |statement|
    machine.execute_sql("database" => "powerdns", "statement" => statement)
  end  
end
