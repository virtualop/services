description "adds forward and reverse entries for a domain"

param :machine
param! "domain", "name of the domain to which this record should belong"
param! 'name', "name of the record to add"
param! 'type', 'the type of record that should be added', :default_value => 'A'
param! "content", "the content to add for the new record"

on_machine do |machine, params|
  id = domain_id(machine, params)
  
  statement = "insert into records (domain_id, name, type, content, ttl) values " +
              "(#{id}, '#{params["name"]}', '#{params['type']}', '#{params["content"]}', 86400)"
  machine.execute_sql("database" => "powerdns", "statement" => statement)
end
