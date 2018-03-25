param :machine
param "count"

run do |machine, count|
  count = count ? "-n#{count} " : ""
  machine.sudo("tail #{count}/var/log/apache2/access.log")
end
