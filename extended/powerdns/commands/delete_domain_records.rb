description "removes entries from the powerdns config database"

param :machine
param! "domain", "name of the domain to which this record should belong"
param! 'name', "name of the records to remove, can contain '%' as SQL wildcards"
  
on_machine do |machine, params|  
  id = domain_id(machine, params)

  statement = "delete from records " + 
              "where domain_id = '#{id}'" +
                "and name like '%#{params['name']}'"
  machine.execute_sql("database" => "powerdns", "statement" => statement)
end