param :machine

param 'owncloud_domain'
param 'username'
param 'password'

on_machine do |machine, params|
  if params['owncloud_domain']
    @op.owncloud_wizard params
  end
end
