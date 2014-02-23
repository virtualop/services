runlevel "infrastructure"

names = {
  "centos" => "mysqld",
  "ubuntu" => "mysql",
  "sles" => "mysql"
}
unix_service names

post_first_start do |machine, params|
  begin
    # TODO we can do this only once
    # TODO hardcoded password
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
