deploy package: %w|ruby ruby-dev ruby-bundler| +
                %w|build-essential| +
                %w|redis-server openssh-server|

# web dependencies
deploy package: %w|libsqlite3-dev zlib1g-dev nodejs|

# TODO make all checkout locations relative to a BASE_DIR?

%w|vop plugins services web|.each do |repo|
  deploy github: "virtualop/#{repo}"
end

deploy do |machine|
  [ "vop", "web" ].each do |dir|
    machine.ssh "cd #{dir} && bundle install"
  end

  machine.write_systemd_config(
    "name" => "vop-web",
    "user" => "marvin",
    "exec_start" => "#{machine.home}/web/bin/web.sh"
  )

  machine.write_systemd_config(
    "name" => "vop-background",
    "user" => "marvin",
    "exec_start" => "#{machine.home}/vop/bin/sidekiq.sh",
    "after" => "redis.service"
  )
end

binary_name "./vop/bin/vop.sh"
icon "vop_16px.png"
