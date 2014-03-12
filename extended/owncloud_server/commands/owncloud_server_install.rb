param :machine
param! "domain"

param 'no_init', 'set to true to skip the initialization (e.g. if you want to see the install screen)', :default_value => false

param 'admin_user', 'user name for the first administrative account', :default_value => 'admin'
param 'admin_password', 'password for the first administrative account', :default_value => 'the_password'

param 'db_type', 'type of database to use', :default_value => 'sqlite'
param 'db_host', 'IP or hostname of the machine where the database is running', :default_value => 'localhost'
param 'db_user'
param 'db_pass'
param 'db_name'

param "ldap_host", "hostname or IP of a LDAP server used for auth"
param "ldap_domain", "the domain that should be used to construct the base DN (e.g. foo.org will be transformed to dc=foo,dc=org)"
param "bind_user", "ldap search string identifying the user to use for binding to the LDAP server (e.g. cn=manager)"
param "bind_password", "the password to use for LDAP binding"
param "selenium_machine", "a machine on which selenium tests can be executed"

on_machine do |machine, params|
  # TODO move into static_html, :document_root => 'foo' ?
  machine.add_static_vhost("server_name" => params["domain"], "document_root" => "/var/www/html/owncloud")
  machine.restart_service 'apache/apache'
  machine.configure_reverse_proxy("domain" => params["domain"])
  
  
  unless params['no_init']
    if params['db_type'] == 'mysql'
      machine.install_canned_service 'my_sql/my_sql'
      machine.create_database('owncloud') unless machine.list_databases.pick(:name).include? 'owncloud'
      sql = "grant all on #{params['db_name']}.* to '#{params['db_user']}'@'localhost' identified by '#{params['db_pass']}'"
      machine.execute_sql('statement' => sql)
    end
    
    init_config = {
      :install => true,
      :adminlogin => params['admin_user'],
      :adminpass => params['admin_password'],
      :directory => '/var/www/html/owncloud/data',
      :dbtype => params['db_type'],
      :dbuser => params['db_user'],
      :dbpass => params['db_pass'],
      :dbname => params['db_name'],
      :dbhost => params['db_host']      
    }
    post_string = init_config.map { |k,v|
      # TODO this does not actually escape
      value = CGI.escapeHTML(v.to_s) 
      [ k.to_s, value ].join('=') 
    }.join('&')

    machine.ssh "curl -c cookies.txt -v -o /dev/null http://#{params["domain"]}/index.php" 
    machine.ssh "curl -b cookies.txt -v -d '#{post_string}' http://#{params["domain"]}/"
  
    if params.has_key?('ldap_host') && params.has_key?('selenium_machine')
      machine.owncloud_ldap(params)
    end
  end
end
