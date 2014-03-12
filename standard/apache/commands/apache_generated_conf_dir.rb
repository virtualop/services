param :machine

on_machine do |machine, params|
  case machine.linux_distribution.split("_").first
  when "sles"
    '/etc/apache2/vhosts.d'
  when "centos"
    '/etc/httpd/conf.d.generated'
  when "ubuntu"
    '/etc/apache2/sites-generated'
  else
    nil
  end
end  
