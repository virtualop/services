param! :machine

param "vop_user", default: "marvin"

run do |machine, vop_user|
  # the vop needs a SSH key to connect to localhost
  machine.generate_keypair

  # vop config in /etc/vop should be writable
  machine.sudo "mkdir /etc/vop"
  machine.sudo "chown #{vop_user}: /etc/vop"
end
