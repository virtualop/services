param :machine

on_machine do |machine, params|
  case machine.linux_distribution.split("_").first
  when "sles"
    '/var/log/apache2'
  when "centos"
    '/var/log/httpd'
  when "ubuntu"
    '/var/log/apache2'
  else
    nil
  end
end  
