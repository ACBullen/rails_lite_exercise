class Static < ControllerBase
  def initialize(app)
    @app = app
  end

  def call(env)
    # res = Rack::Response.new
    # right_path = Regexp.new('^/path/.+')
    # cap = Regexp.new('^/path/(.+)')
    # @path = env.
    # filename = @path.match(right_path).captures.first
    # res.write(File.read("public/#{filename}"))
    # res.finish
  end

  def serve
    cap = Regexp.new('^/path/(.+)')
    @path = env.
    filename = @path.match(right_path).captures.first
    res.write(File.read("public/#{filename}"))
    res.finish
  end
end
