param! :machine

show columns: %w|remote_ip timestamp request status|

run do |machine|
  @op.parse_access_log(machine.tail_access_log)
end
