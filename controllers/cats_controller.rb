require 'require_all'
require_relative '../models/cat'
require_relative '../models/human'
require_relative '../lib/params'
require 'byebug'

class CatsController < ControllerBase
  def index
    flash.now["errors"] = ["I'm a flash.now"]
    flash["errors"] = ["I'm a flash"]
    @cats = Cat.all
  end

  def new
    @cat = Cat.new
  end

  def create
    owner = Human.where(fname: params["cat"]["owner"]).first
    @cat = Cat.new(name: params["cat"]["name"], owner_id: owner.id)
    if @cat.insert
      redirect_to("cats")
    else
      flash.now["errors"] = "incorrect name or owner"
      render :new
    end
  end

end
