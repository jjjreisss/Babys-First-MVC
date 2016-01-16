require 'rack'
require 'require_all'
require_relative '../lib/controller_base'
require_relative '../lib/router'
require_relative 'middleware'
require_rel '../controllers/*'


$cats = [
  { id: 1, name: "Curie" },
  { id: 2, name: "Markov" }
]

$statuses = [
  { id: 1, cat_id: 1, text: "Curie loves string!" },
  { id: 2, cat_id: 2, text: "Markov is mighty!" },
  { id: 3, cat_id: 1, text: "Curie is cool!" }
]


router = Router.new
router.draw do
  get Regexp.new("^/cats/new$"), CatsController, :new
  get Regexp.new("^/cats$"), CatsController, :index
  get Regexp.new("^/cats/(?<cat_id>\\d+)$"), CatsController, :show
  post Regexp.new("^/cats$"), CatsController, :create
  get Regexp.new("^/cats/(?<cat_id>\\d+)/statuses$"), StatusesController, :index
  get Regexp.new("^/dogs/new$"), DogsController, :new
  get Regexp.new("^/dogs$"), DogsController, :index
  get Regexp.new("^/dogs/(?<dog_id>\\d+)$"), DogsController, :show

end

app_without_middleware = Proc.new do |env|
  req = Rack::Request.new(env)
  res = Rack::Response.new
  router.run(req, res)
  res.finish
end

app = Rack::Builder.new do
  use Errorware
  use Pictureware
  run app_without_middleware
end

Rack::Server.start(
 app: app,
 Port: 3000
)
