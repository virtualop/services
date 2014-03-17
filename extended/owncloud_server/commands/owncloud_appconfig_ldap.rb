description "modifies the owncloud configuration stored in a mysql database so that it authenticates against a LDAP server"

param :machine
param! "domain"

param! "ldap_host", "hostname or IP of a LDAP server used for auth"
param! "ldap_domain", "the domain that should be used to construct the base DN (e.g. foo.org will be transformed to dc=foo,dc=org)"
param "bind_user", "ldap search string identifying the user to use for binding to the LDAP server (e.g. cn=manager)"
param "bind_password", "the password to use for LDAP binding"

on_machine do |machine, params|
  # TODO this is copied from owncloud_ldap, merge
  ldap_base = CGI.escapeHTML(params['ldap_domain'].split('.').map { |x| "dc=#{x}" }.join(','))
    
  bind_user = CGI.escapeHTML(params["bind_user"])
  bind_password = params['bind_password']
  
  # TODO hardcoded password ;-)
  config = read_local_template(:oc_appconfig_ldap, binding())
  config.split("\n").each do |line|
    (k, v) = line.split(' ')
    update = "insert into oc_appconfig(appid, configkey, configvalue) " +
             "values ('user_ldap', '#{k}', '#{v}') " +
             "on duplicate key update configvalue = '#{v}'"
    machine.execute_sql('database' => 'owncloud', 'statement' => update)
    @op.comment(update)
  end
end
