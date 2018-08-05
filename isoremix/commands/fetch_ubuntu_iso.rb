param! :machine

param! "version", :default => "16.04"

run do |machine, version|
  dir = isoremix_dir("clean")

  upstream_url = "http://releases.ubuntu.com/#{version}"

  input = machine.curl "#{upstream_url}/"
  links = input.scan /<a href="(ubuntu-(#{version}[\.\d]+)-(?:live-)?(.+?)-(.+?)\.([^>]+))">/

  files = links.map do |link|
    {
      url: "#{upstream_url}/#{link[0]}",
      version: link[1],
      type: link[2],
      arch: link[3],
      extension: link[4]
    }
  end

  isos = files.select do |file|
    file[:extension] == "iso" &&
    file[:arch] == "amd64" &&
    file[:type] == "server"
  end

  iso = isos.first
  raise "no ISO found" if iso.nil?

  url = iso[:url]
  $logger.info "found URL : #{url}"

  file_name = url.split("/").last
  machine.download_file(
    url: url,
    file: "#{dir}/#{file_name}"
  )
end
