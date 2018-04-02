deploy package: %w|ruby ruby-dev redis-server|
deploy package: "openssh-server"
deploy gem: %w|vop vop-plugins vop-services|

binary_name "vop"
icon "vop_16px.png"
