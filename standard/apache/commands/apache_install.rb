description "installs an apache httpd server"

param :machine

on_machine do |m, params|
  m.as_user("user_name" => "root") do |machine|
    # TODO for some reason, it seems that the cache for file_exists ".../welcome.conf" isn't invalidated correctly
    @op.without_cache do
      if machine.file_exists("file_name" => "/etc/httpd/conf.d/welcome.conf")
        machine.rm("file_name" => "/etc/httpd/conf.d/welcome.conf")
      end 
    end
      
    if machine.linux_distribution.split("_").first == "centos"
      process_local_template(:httpd_conf, machine, "/etc/httpd/conf/httpd.conf", binding())
    elsif machine.linux_distribution.split("_").first == "sles"
      machine.replace_in_file("file_name" => "/etc/apache2/listen.conf",
        "source" => "\#NameVirtualHost \\*:80",
        "target" => "NameVirtualHost *:80"
      )
    end
    
    generated_dir = machine.apache_generated_conf_dir
    machine.mkdir("dir_name" => generated_dir) unless generated_dir == nil
    
    target_file_name = "/var/www/html/index.html"
    process_local_template(:index_html, machine, target_file_name, binding())
    machine.allow_access_for_apache("file_name" => target_file_name)
    
    if %w|sles ubuntu|.include? machine.distro
      %w|proxy proxy_http proxy_balancer rewrite|.each do |mod|
        machine.ssh "a2enmod #{mod}"
      end
    end
    
    if machine.file_exists('/etc/apache2/conf-available') && machine.file_exists('/etc/apache2/conf-enabled')
      process_local_template(:custom_log, machine, "/etc/apache2/conf-available/logformat_vop.conf", binding())
      machine.ssh 'cd /etc/apache2/conf-enabled && ln -s ../conf-available/logformat_vop.conf'
    elsif machine.file_exists('/etc/apache2/conf.d')
      process_local_template(:custom_log, machine, "/etc/apache2/conf.d/logformat_vop.conf", binding())
    end
  end
end
