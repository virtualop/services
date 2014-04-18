param :machine
param! "user", "name of the user account in whose context rvm should be installed"
param "ruby_version", "a version of ruby to install using the newly installed rvm"
param "rvm_version", "a specific version of RVM that should be installed"

# TODO needs_sudo

on_machine do |m, params|
  
  install_block = lambda do |where|
    tmp_dir = "/home/#{params["user"]}/tmp"
    where.mkdir tmp_dir
    where.ssh("cd #{tmp_dir} && curl -k -L https://get.rvm.io > rvm_io.sh && chmod +x rvm_io.sh")
    
    rvm_version = params.has_key?("rvm_version") ? params["rvm_version"] : ''
    where.ssh("cd #{tmp_dir} && ./rvm_io.sh #{rvm_version}")
    
    where.rvm_ssh("rvm get stable")
    where.rvm_ssh("rvm get head --auto-dotfiles")
    
    if params.has_key?("ruby_version")
      where.rvm_ssh("rvm install #{params["ruby_version"]} --verify-downloads 1")
    end
  end

  if params['user']
    m.as_user("user_name" => params["user"]) do |machine|
      install_block.call(machine)
    end
  else
    install_block.call(m)
  end  
end