require 'active_support'
require 'active_support/core_ext'
require 'erb'
require 'require_all'
require_relative './session'
require_relative './flash'
require_relative 'params'

class ControllerBase
  attr_reader :req, :res, :params

  # Setup the controller
  def initialize(req, res, route_params = {})
    @req = req
    @res = res
    @params = Params.new(req, route_params)
  end

  # Helper method to alias @already_built_response
  def already_built_response?
    @already_built_response
  end

  # Set the response status code and header
  def redirect_to(url)
    @res['Location'] = url
    @res.status = 302
    session.store_session(@res)
    flash.store_flash(@res)
    raise 'error' if already_built_response?
    @already_built_response = true
  end

  # Populate the response with content.
  # Set the response's content type to the given type.
  # Raise an error if the developer tries to double render.
  def render_content(content, content_type)
    @res['Content-Type'] = content_type
    @res.body = [content]
    session.store_session(@res)
    flash.store_flash(@res)
    raise 'error' if already_built_response?
    @already_built_response = true
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    controller_name = self.class.to_s.underscore[0..-12]
    template = File.read("views/#{controller_name}/#{template_name}.html.erb")
    template = ERB.new(template)
    content = template.result(binding)
    render_content(content, 'text/html')
  end

  # method exposing a `Session` object
  def session
    @session ||= Session.new(req)
  end

  def flash
    @flash ||= Flash.new(req)
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
    send(name)
    render(name) unless already_built_response?
  end
end
