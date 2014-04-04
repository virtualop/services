param :machine

on_machine do |machine, params|
  result = []
  machine.list_files(config_string('screenshot_path')).each do |file|
    if /_(\d+).png$/ =~ file
      result << $1
    end
  end
  result
end
