description "installation script for hello_world"

param :machine
param! 'domain'
param! 'user_name'
param 'service_root', '', :default_value => '/var/www/html'

on_machine do |machine, params|
  user_name = params['user_name'] || 'foo'
  machine.as_user('root') do |root|
    process_local_template(:index, root, '/var/www/html/index.html', binding())
  end
end
