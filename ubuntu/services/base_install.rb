deploy do |machine|
  machine.set_hostname machine.name.split(".").first
  # TODO set the domain as well?

  machine.sudo "apt-get update"
  machine.sudo "apt-get upgrade -y"

  machine.install_package "apt-transport-https"
end
