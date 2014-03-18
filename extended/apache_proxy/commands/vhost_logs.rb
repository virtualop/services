param :machine

tab 'vhost_logs', 'vhost logz', @plugin.path + '/tabs/vhost_logs.erb'

on_machine do |machine, params|
  result = {
    :graphs => [],
    :overall_max => 0 # of successful requests on a vhost 
  }
  
  machine.list_configured_vhosts.each do |vhost|
    if vhost['log_path']
      params[:interval] ||= 'hour'
      graph_data = nil
      begin          
        data = machine.read_logfile(
          "path" => vhost['log_path'],
          'interval' => 'hour',
          'count' => 5,
          "for_flot" => "true", 
          "tz_offset" => 0, # TODO current_user.utc_offset,
          "line_count" => params[:lines] || 1000,
          'wanted' => [ 'stats' ]
        )
        graph_data = data['stats']
      rescue => detail
        $logger.warn("could not render graph from log : #{detail.message}\n#{detail.backtrace[0..19].join("\n")}")
      end
    
      if graph_data   
        domain_name = vhost['domain']#.gsub('.', '_')
        graph_data.delete :response_time_ms
        if graph_data.keys.size > 0
          result[:graphs] << [ domain_name, graph_data ]
          
          if graph_data.has_key? :success
            puts "+++ #{domain_name} +++"
            #pp graph_data[:success][:data].map { |x| x.last }
            #graph_max = 42 #
            graph_max = graph_data[:success][:data].map { |x| x.last }.max
            result[:overall_max] = graph_max if graph_max > result[:overall_max]
          end
        end
      end
    end 
  end
  
  result
end  