param :machine, 'a rpmbuild machine'
param! 'github_repo'
param 'rpm_name'
param 'tree', 'a github branch or release to use', :default_value => 'master'
param 'source_repo', 'extra github repo that should be downloaded and used as source', :allows_multiple_values => true
param 'target_dir', 'the directory where the created RPMS should be copied to',
  :default_value => '/var/www/html/packages/rpm'  

accept_extra_params

on_machine do |machine, params|
  target_dir = params['target_dir']
  
  params['source_repo'].each do |source_repo|
    p = params.clone
    p.delete 'rpm_name'
    p['github_repo'] = source_repo    
    @op.rpm_tarball_from_github(p)
  end if params['source_repo']
  
  tarball = @op.rpm_tarball_from_github(params)
  
  vars = params['extra_params'].map { |k,v|
    value = v.is_a?(Array) ? v.first : v 
    "--define \"#{k} #{value}\"" 
  }.join(' ')
  
  output = machine.ssh "rpmbuild #{vars} -ta #{tarball}"
  
  rpm_path = nil  
  output.split("\n").each do |line|
    line.chomp!
    if /Wrote: (.+\/RPMS\/.+.rpm)$/.match(line)
      rpm_path = $1
      machine.ssh "cp #{rpm_path} #{target_dir}/"
      machine.ssh "createrepo #{target_dir}"    
      break
    end
  end
  
  rpm_path
end

