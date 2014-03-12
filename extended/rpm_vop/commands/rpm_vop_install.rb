param :machine

on_machine do |machine, params|
  machine.as_user('marvin') do |better_safe_than_sorry|
    # just because you're paranoid does not mean they are not out there looking for you
    better_safe_than_sorry.vop_call('command' => 'vop_init', 'extra_params' => { 
    'domain' => 'localhost' 
    })
  end
end
