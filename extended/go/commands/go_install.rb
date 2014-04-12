param :machine

on_machine do |machine, params|
  go_file = "/tmp/hello.go"
  process_local_template(:sample, machine, go_file, binding())
  output = machine.ssh "go run #{go_file}"
  @op.comment "go says >> #{output}"
  
  # set up GOPATH
  bashrc = "#{machine.home}/.bashrc"
  if machine.file_exists(bashrc)
    go_path = "#{machine.home}/go"
    machine.mkdir go_path
    machine.append_to_file(
      'file_name' => bashrc, 
      'content' => "export GOPATH=#{go_path}"
    )
  end
end
