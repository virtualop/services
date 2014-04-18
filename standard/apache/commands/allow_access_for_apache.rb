description "changes the permissions of a file so that the apache service can access it"

param :machine
param! "file_name", "path to the file that should be modified", :default_param => true

on_machine do |machine, params|
  www_user = case machine.linux_distribution.split("_").first
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
    as_root.chown("file_name" => file_name, "ownership" => ":#{www_user}") unless www_user == nil
  end
end  