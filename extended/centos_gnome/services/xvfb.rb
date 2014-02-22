run_command "Xvfb :1 -screen 0 1024x768x24 &"
process_regex "Xvfb \:1"