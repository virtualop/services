description "changes the permissions of a file so that the apache service can read it"

param :machine
param! "file_name", "path to the file that should be modified"

on_machine do |machine, params|
  apache_user = case machine.linux_distribution.split("_").first
  when "ubuntu"
    "www-data"
  when "sles"
    "wwwrun"
  when "centos"
    "apache"
  else
    nil
  end
  file_name = params['file_name']
  machine.as_user("root") do |as_root|
    as_root.chown("file_name" => file_name, "ownership" => ":#{apache_user}") unless apache_user == nil
    as_root.chmod("file_name" => file_name, "permissions" => "g+rx")
  end
end  