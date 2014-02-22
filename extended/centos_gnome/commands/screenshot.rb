param :machine

param 'dir_name', 'the directory where the screenshot should be stored', :default_value => config_string('screenshot_path')
param 'file_name'

on_machine do |machine, params|
  file_name = params['file_name'] || "#{machine.name}_#{Time.now.utc.to_i}.png"
  full_name = params['dir_name'] + '/' + file_name
    
  machine.ssh "import -window root #{full_name}"
  machine.as_user('root') do |root|
    root.chown('file_name' => full_name, 'ownership' => 'marvin.apache')
  end
  full_name
end
