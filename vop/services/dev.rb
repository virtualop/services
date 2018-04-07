deploy package: %w|ruby ruby-dev ruby-bundler| +
                %w|build-essential| +
                %w|redis-server openssh-server|

%w|vop plugins services|.each do |repo|
  deploy github: "virtualop/#{repo}"
end

binary_name "./vop/bin/vop.sh"
icon "vop_16px.png"
