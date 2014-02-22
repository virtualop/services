param :machine

param! 'owncloud_domain'
param! 'username'
param! 'password'

on_machine do |machine, params|
  # skip the "New version available" message (only available on first install)
  machine.ssh "xdotool key Return"
  machine.screenshot
  
  owncloud_domain = params['owncloud_domain']
  
  machine.ssh "xdotool type 'http://#{owncloud_domain}'"
  machine.ssh 'xdotool key Tab'
  machine.ssh 'xdotool key Return'
  machine.screenshot
  
  #machine.ssh 'xdotool key Tab'
  machine.ssh "xdotool type '#{params['username']}'" #"\t#{params['password']}\t\t'"
  machine.ssh 'xdotool key Tab'
  machine.ssh "xdotool type '#{params['password']}'"
  machine.ssh 'xdotool key Tab'
  machine.ssh 'xdotool key Tab'

  machine.screenshot
  machine.ssh 'xdotool key Return'
  sleep 2
  machine.screenshot
  
  machine.ssh 'xdotool key Return'
  sleep 2
  machine.screenshot
  
  machine.ssh 'xdotool key Alt+f'
  sleep 1
  machine.screenshot
end
