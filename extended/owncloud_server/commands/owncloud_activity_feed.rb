param :machine

param! 'credentials', 'user and password, separated by slash ("/")'

on_machine do |machine, params|
  domain = machine.service_details('owncloud_server/owncloud_server')['domain']
  if domain.is_a?(Array)
    domain = domain.first
  end
  p = {
    'url' => "http://#{domain}/index.php/apps/activity/rss.php"
  }
  creds = params['credentials'].split('/')
  p.merge!(
    'user' => creds.first,
    'password' => creds.last 
  )
  rss = @op.http_get(p)
  data = rss
  #data = XmlSimple.xml_in(rss)
  pp data
  data
end
