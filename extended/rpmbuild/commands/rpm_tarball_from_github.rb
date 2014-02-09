param :machine, 'a rpmbuild machine'
param! 'github_repo'
param 'rpm_name'
param 'tree', 'a github branch or release to use', :default_value => 'master'

on_machine do |machine, params|
  sources = "#{machine.home}/rpmbuild/SOURCES"
  
  github_repo = params['github_repo']
  tree = params['tree']
  target = params['rpm_name'] ? params['rpm_name'] : "#{github_repo.gsub('/', '-')}-#{tree}"
  
  machine.wget("target_dir" => sources, "url" => "https://github.com/#{github_repo}/archive/#{tree}.tar.gz")
  
  # we get an archive with the name of the tree
  # inside is a folder that is the repo name (without owner) and the tree
  extracted = github_repo.split('/').last + '-' + tree
  
  # so we extract, rename and compress again
  machine.ssh "cd #{sources} && tar -xzf #{tree} && rm #{tree}"
  unless extracted == target 
    machine.ssh "cd #{sources} && mv #{extracted} #{target}"
  end
  tarball = "#{target}.tgz" 
  machine.ssh "cd #{sources} && tar -czf #{tarball} #{target} && rm -rf #{target}"
  
  "#{sources}/#{tarball}"
end

