def domain_id(machine, params)
  data = mysql_xml_to_rhcp machine.execute_sql(
    "database" => "powerdns", 
    "statement" => "select id from domains where name = '#{params["domain"]}'",
    "xml" => "true"
  )
  data.first["id"]
end
