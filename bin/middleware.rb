require 'coderay'

class Errorware
  attr_reader :app
  def initialize(app)
    @app = app
  end

  def call(env)
    begin
      app.call(env)
    rescue => detail
      res = Rack::Response.new
      res.status = 200
      res['Content-Type'] = 'text/html'
      make_template(detail)
      template = ERB.new(File.read("views/errors.html.erb"))
      res.body = [template.result(binding)]
      res.finish
    end
  end

  def make_template(error)
    @traces = error.backtrace
    first_line = @traces.first
    error_args = first_line.split(":")
    error_path = error_args[0]
    error_file = File.readlines(error_path)
    error_line_no = error_args[1].to_i
    @error_source = error_file[error_line_no-8, error_line_no+8].join()
    @error_source = CodeRay.scan(@error_source, :ruby).div(:line_numbers => :table)
  end

end

class Pictureware
  attr_reader :app
  def initialize(app)
    @app = app
  end

  def call(env)
    begin
      app.call(env)
    rescue Exception => path
      res = Rack::Response.new
      res.status = 200
      content_type = path.message.split(".").last
      res['Content-Type'] = content_type
      file = File.read(path.message[1..-1])
      res.body = [file]
      res.finish
    end
  end

end
