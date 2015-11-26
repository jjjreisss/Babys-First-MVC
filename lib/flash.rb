require 'json'

class Flash
#flash gets set and sent back with the response
  #to be rendered by the next controller
#flash.now gets set and cleared before sending back the response
  #only gets rendered by current controller
#now_cookie will store all the display for this controller
#later_cookie will store all the display for next controller
  attr_reader :now

  def initialize(req)
    @later = {}
    if req.cookies['_rails_lite_flash']
      @now = JSON.parse(req.cookies['_rails_lite_flash'])
    else
      @now = {}
    end
  end

  def [](key)
    if @later[key]
      @now[key].concat(@later[key])
    else
      @now[key]
    end
  end

  def []=(key, val)
    @later[key] = val
  end

  def store_flash(res)
    res.set_cookie('_rails_lite_flash', {:path => "/", :value => @later.to_json})
  end

end
