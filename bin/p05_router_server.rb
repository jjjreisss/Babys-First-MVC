require 'rack'
require_relative '../lib/controller_base'
require_relative '../lib/router'
require_relative 'middleware'


$cats = [
  { id: 1, name: "Curie" },
  { id: 2, name: "Markov" }
]

$statuses = [
  { id: 1, cat_id: 1, text: "Curie loves string!" },
  { id: 2, cat_id: 2, text: "Markov is mighty!" },
  { id: 3, cat_id: 1, text: "Curie is cool!" }
]

class StatusesController < ControllerBase
  def index
    statuses = $statuses.select do |s|
      s[:cat_id] == Integer(params['cat_id'])
    end

    render_content(statuses.to_s, "text/text")
  end
end

class CatsController < ControllerBase
  def index
    # render_content($cats.to_s, "text/text")
    flash.now["errors"] = ["I'm a flash.now"]
    flash["errors"] = ["I'm a flash"]

    # redirect_to "cats/new"
  end

  def new
  end

end

router = Router.new
router.draw do
  get Regexp.new("^/cats/new$"), CatsController, :new
  get Regexp.new("^/cats$"), CatsController, :index
  get Regexp.new("^/cats/(?<cat_id>\\d+)/statuses$"), StatusesController, :index
end

lame_app = Proc.new do |env|
  req = Rack::Request.new(env)
  res = Rack::Response.new
  router.run(req, res)
  res.finish
end

app = Rack::Builder.new do
  use Errorware
  use Pictureware
  run lame_app
end

Rack::Server.start(
 app: app,
 Port: 3000
)
