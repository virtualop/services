description "adds forward and reverse entries for a domain"

param :machine
param! "domain", "name of the domain to which this record should belong"
param! 'name', "name of the record to add"
param! 'type', 'the type of record that should be added', :default_value => 'A'
param! "content", "the content to add for the new record"

on_machine do |machine, params|
  data = mysql_xml_to_rhcp machine.execute_sql("database" => "powerdns", "statement" => "select id from domains where name = '#{params["domain"]}'", "xml" => "true")
  id = data.first["id"]
  
  [
    "insert into records (domain_id, name, type, content, ttl) values " +
                        "(#{id}, '#{params["name"]}', '#{params['type']}', '#{params["content"]}', 86400)"
  ].each do |statement|
    machine.execute_sql("database" => "powerdns", "statement" => statement)
  end
end
