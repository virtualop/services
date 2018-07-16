binary_name "./vop/bin/vop.sh"
icon "vop_16px.png"

deploy package: %w|ruby ruby-dev ruby-bundler| +
                %w|build-essential| +
                %w|redis-server openssh-server|

# web dependencies
deploy package: %w|libsqlite3-dev zlib1g-dev nodejs|

# TODO make all checkout locations relative to a BASE_DIR?

%w|vop plugins services web|.each do |repo|
  deploy github: "virtualop/#{repo}"
end

param! "domain"

deploy do |machine, params|
  [ "vop", "web" ].each do |dir|
    machine.ssh "cd #{dir} && bundle install"
  end

  machine.write_systemd_config(
    "name" => "vop-web",
    "user" => "marvin",
    "exec_start" => "#{machine.home}/web/bin/web.sh",
    "after" => "redis.service"
  )

  machine.write_systemd_config(
    "name" => "vop-background",
    "user" => "marvin",
    "exec_start" => "#{machine.home}/vop/bin/sidekiq.sh",
    "after" => "redis.service"
  )

  machine.write_systemd_config(
    "name" => "vop-message-pump",
    "user" => "marvin",
    "exec_start" => "#{machine.home}/web/bin/message-pump.sh",
    "after" => "redis.service"
  )

  %w|vop-web vop-background vop-message-pump|.each do |name|
    machine.enable_systemd_service name
    machine.start_systemd_service name
  end

  machine.install_service("apache.reverse_proxy")
  machine.add_reverse_proxy(
    server_name: params["domain"],
    target_url: "http://localhost:3000/"
  )
  machine.parent.reverse_proxy.add_reverse_proxy(
    server_name: params["domain"],
    target_url: "http://#{machine.internal_ip}/"
  )

  machine.vop_init
end
