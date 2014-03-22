param :machine

param "domain", "if specified, the nameserver is preconfigured for the specified domain"
param "ip", "if specified, a set of A and PTR records will be created for the domain and IP"

on_machine do |machine, params|
  process_local_template(:pdns_conf, machine, "/etc/powerdns/pdns.conf", binding())
  
  machine.create_database("name" => "powerdns") unless machine.list_databases.select { |x| x["name"] == "powerdns" }.size > 0
  
  sql = read_local_template(:database, binding())
  machine.execute_sql("database" => "powerdns", "statement" => sql)
  
  if params["domain"]
    @op.prepare_domain_config(params)
  end
end
