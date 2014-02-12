param :machine

on_machine do |machine, params|
  begin
    mysql_user = config_string('mysql_user', '')
    if mysql_user == 'root'
      new_password = config_string('mysql_password', '')
      if new_password != ''
        machine.ssh "mysqladmin -u root password #{new_password}"
      end
    end
  rescue
  end   
end
