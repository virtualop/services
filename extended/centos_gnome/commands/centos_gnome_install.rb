param :machine

param 'domain', 'a domain to publish screenshots'

as_root do |root, params|
  root.ssh('yum groupinstall -y "Desktop" "X Window System"')
  
  # prepare screenshot dir
  path = config_string('screenshot_path')
  root.mkdir path
  root.chown('file_name' => path, 'ownership' => 'marvin.apache')
  root.chmod('file_name' => path, 'permissions' => 'g+r')
  
  # configure DISPLAY
  process_local_template(:profile, root, '/etc/profile.d/centos_gnome.sh', binding())
  root.chmod('file_name' => '/etc/profile.d/centos_gnome.sh', 'permissions' => 'go+r')
  
  # just a workaround
  root.ssh 'dbus-uuidgen > /var/lib/dbus/machine-id'

  # install subservices  
  @op.with_machine(params['machine']) do |machine|
    [ 'xvfb', 'gnome', 'gnome_panel' ].each do |x|
      machine.install_canned_service("centos_gnome/#{x}")
    end
  end
end
