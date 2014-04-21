description "installation script for github_dev"

param :machine
param :current_user

on_machine do |machine, params|
  machine.prepare_github_ssh_connection
  
  public_key = machine.read_file "#{machine.home}/.ssh/id_rsa.pub"
  @op.add_ssh_key('title' => machine.name, 'key' => public_key)
end
