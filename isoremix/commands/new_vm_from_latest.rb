param! :machine

param! "name"

param "memory", description: "in MB", default: 512
param "cpu_count", default: 1
param "disk_size", description: "in GB", default: 25

param! "iso_regex", "a regular expression to filter ISO names against"

run do |machine, params|
  iso_regex = Regexp.new(params.delete("iso_regex"))

  found = machine.list_rebuilt_isos.select do |iso|
    iso["name"] =~ iso_regex
  end
  raise "no rebuilt ISO found matching name pattern #{iso_regex}" unless found && found.size > 0
  iso_name = found.sort_by { |x| x["timestamp"] }.last["name"]

  $logger.info "latest ISO found : #{iso_name}"
  @op.new_vm_from_iso(params.merge({"iso" => iso_name}))
end
