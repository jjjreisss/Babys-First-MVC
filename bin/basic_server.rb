require 'rack'

app = Proc.new do |env|
  req = Rack::Request.new(env)
  url = req.fullpath
  res = Rack::Response.new
  res['Content-Type'] = 'text.html'
  res.write(url)
  res.finish
end

Rack::Server.start(
  app: app,
  Port: 3000
)
