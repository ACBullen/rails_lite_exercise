require 'json'

class Flash
  attr_accessor :flash, :now
  def initialize(req)
    incoming = req.cookies["_rails_lite_app_flash"]
    incoming = JSON.parse(incoming) if incoming
    @original = incoming || {}
    @flash = {}
    @flash[:path] = '/'
    @now = {}
  end

  def [](key)
    key = key.to_s
    @original[key] || @flash[key] || @now[key]
  end

  def []=(key, val)
    key = key.to_s
    @flash[key] = val
  end

  def store_flash(res)
    res.set_cookie("_rails_lite_app_flash", @flash.to_json)
  end
end
