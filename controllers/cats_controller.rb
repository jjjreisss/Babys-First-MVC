require 'require_all'
require_relative '../models/cat'
require_relative '../lib/params'
require 'byebug'

require_rel '../active-record-create/lib/*'
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
    @cat = Cat.new(name: params["cat"]["name"], owner_id: params["cat"]["owner_id"])
    if @cat.insert
      redirect_to("cats")
    else
      flash.now["errors"] = "incorrect name or owner"
      render :new
    end
  end

end
