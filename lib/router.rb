class Route
  attr_reader :pattern, :http_method, :controller_class, :action_name

  def initialize(pattern, http_method, controller_class, action_name)
    @pattern = pattern
    @method = http_method
    @controller = controller_class
    @action = action_name
  end

  # checks if pattern matches path and method matches request method
  def matches?(req)

    req.request_method.downcase == @method.to_s && @pattern =~ req.fullpath
  end

  # use pattern to pull out route params (save for later?)
  # instantiate controller and call controller action
  def run(req, res)
    regex = Regexp.new @pattern
    match_data = regex.match(req.fullpath)
    route_hash = {}
    match_data.names.each do |name|
      route_hash[name] = match_data[name]
    end
    inst = @controller.new(req, res, route_hash)
    inst.invoke_action(@action)
  end
end

class Router
  attr_reader :routes

  def initialize
    @routes = []
    @routes << Route.new(Regexp.new("/^public/*"), "get", Static, :serve )
  end

  # simply adds a new route to the list of routes
  def add_route(pattern, method, controller_class, action_name)
    @routes << Route.new(pattern, method, controller_class, action_name)
  end

  # evaluate the proc in the context of the instance
  # for syntactic sugar :)
  def draw(&proc)
    self.instance_eval(&proc)
  end

  # make each of these methods that
  # when called add route
  [:get, :post, :put, :delete].each do |http_method|
    define_method(http_method) do |pattern, controller_class, action|
      add_route(pattern, http_method, controller_class, action)
    end
  end

  # should return the route that matches this request
  def match(req)
    @routes.each do |route|
      return route if route.matches?(req)
    end
    nil
  end

  # either throw 404 or call run on a matched route
  def run(req, res)
    matching_route = match(req)
    if matching_route
      matching_route.run(req, res)
    else
      res.status = 404
    end
  end
end
