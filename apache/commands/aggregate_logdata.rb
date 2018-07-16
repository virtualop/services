param! "data", "the parsed entries to aggregate (array of hashes)", multi: true

param "interval", lookup: lambda { %w|minute hour day week| }, default: "hour"

run do |data, interval|
  raw = {}

  $logger.info("target interval : #{interval}")

  data.each do |entry|
    if entry.nil?
      $logger.warn("null entry while aggregating logdata")
    else
      apache_timestamp = entry[:timestamp]
      # 15/Jul/2018:21:00:22 +0200
      if matched = /(\d+\/\w+\/\d{4}):([\d:]+)\s+([\+\d]+)/.match(apache_timestamp)
        parseable = matched.captures[0] + " " + matched.captures[1] + " " + matched.captures[2]
        $logger.info ("converted #{apache_timestamp} into #{parseable}")

        timestamp = DateTime.parse(parseable)
        adjusted_timestamp = timestamp.strftime("%s").to_i
        if %w|minute hour day week|.include? interval
          adjusted_timestamp -= timestamp.sec
        end
        if %w|hour day week|.include? interval
          adjusted_timestamp -= timestamp.min * 60
        end
        if %w|week|.include? interval
          adjusted_timestamp -= timestamp.hour * 60 * 60
        end
        adjusted_timestamp = Time.at(adjusted_timestamp)
        $logger.info "adjusted : #{timestamp} -> #{adjusted_timestamp}"

        selector = if entry[:status]
          entry[:status].to_i < 400 ? :success : :failure
        else
          :unknown
        end

        raw[selector] = {} unless raw.has_key? selector
        hash = raw[selector]

        hash[adjusted_timestamp] = [] unless hash.has_key? adjusted_timestamp
        hash[adjusted_timestamp] << entry
      else
        $logger.warn("unexpected timestamp format: '#{apache_timestamp}'")
      end
    end
  end

  aggregated = {}

  raw.each do |selector, e|
    e.keys.sort.each do |bucket|
      aggregated[selector] = [] unless aggregated.has_key? selector
      aggregated[selector] << [
        bucket, e[bucket].size
      ]
    end
  end

  out_count = 0
  raw[:success].keys.sort.each do |ts|
    bucket = raw[:success][ts]
    total = 0
    count = 0
    bucket.each do |entry|
      if entry[:response_time_microsecs]
        count += 1
        total += entry[:response_time_microsecs].to_i / 1000
      end
    end

    if count > 0
      avg = total / count
      aggregated[:response_time_ms] ||= []
      aggregated[:response_time_ms] << [
        ts, avg
      ]
    end

    if out_count < 5
      puts "total for #{ts} : #{total}, count #{count} of #{bucket.size}. avg: #{avg}"
      out_count += 1
    end
  end unless raw[:success] == nil

  aggregated
end
