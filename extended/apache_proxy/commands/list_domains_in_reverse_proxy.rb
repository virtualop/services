description "same data as list_domains_pointing_to_machine, formatted for contribution"

contributes_to :list_domains

param :machine

on_machine do |machine, params|
  machine.list_domains_pointing_to_machine.map do |x|
    { 'domain' => x } 
  end
end
