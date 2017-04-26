require 'active_support'
require 'active_support/core_ext'
require 'erb'
require_relative './session'
require 'byebug'
require 'active_support/inflector'


class ControllerBase
  attr_reader :req, :res, :params

  # Setup the controller
  def initialize(req, res, params = {})
    @res = res || Rack::Response.new
    @req = req || Rack::Request.new
    @params = params
  end

  # Helper method to alias @already_built_response
  def already_built_response?
     @already_built_response
  end

  # Set the response status code and header
  def redirect_to(url)
    raise "Already responded" if already_built_response?
    @res['Location'] = url
    @res.status = 302

    session.store_session(@res)
    @already_built_response = true
  end

  # Populate the response with content.
  # Set the response's content type to the given type.
  # Raise an error if the developer tries to double render.
  def render_content(content, content_type)
    raise "Already responded" if already_built_response?

    @res['Content-Type'] = content_type
    @res.write(content)

    session.store_session(@res)
    @already_built_response = true
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    raise "Already responded" if already_built_response?

    class_name = self.class.to_s.underscore
    @location = "views/#{class_name}/#{template_name}.html.erb"
    @contents = File.read("#{@location}")
    @template = ERB.new(@contents)

    render_content(@template.result(binding), 'text/html')
    @already_built_response = true
  end

  # method exposing a `Session` object
  def session
    @session ||= Session.new(@req)
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
    self.send(name.to_sym)
    unless already_built_response?
      render name.to_sym
    end
  end
end
