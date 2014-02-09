param :machine
param 'domain'
param 'service_root', 'path to the folder where packages should be published at +domain+', 
  :default_value => '/var/www/html/packages/rpm' 

on_machine do |machine, params|
  machine.ssh 'rpmdev-setuptree'
  
  machine.as_user('root') do |root|
    root.mkdir params['service_root']
    root.chown('file_name' => params['service_root'], 'ownership' => 'marvin.apache')
    root.chmod('file_name' => params['service_root'], 'permissions' => 'g+rx')
  end
  machine.ssh "createrepo #{params['service_root']}"
end