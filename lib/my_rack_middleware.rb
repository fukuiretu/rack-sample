class MyRackMiddleware
  def self.configure
    yield @config ||= MyRackMiddleware::Config.new
  end

  def self.config
    @config
  end

  def initialize(app)
    @app = app
  end

  def call(env)
    if env["PATH_INFO"] == '/hoge'
      res = []
      res[0] = 200
      res[2] = [ MyRackMiddleware.config.dummy ]
      content_length = res[2].inject(0) do |sum, content|
        sum + content.bytesize
      end
      res[1] = { "Content-Type"           => "text/html;charset=utf-8",
                 "Content-Length"         => content_length.to_s,
                 "X-XSS-Protection"       => "1; mode=block",
                 "X-Content-Type-Options" => "nosniff",
                 "X-Frame-Options"        => "SAMEORIGIN"}
    else
      res = @app.call(env)
    end

    res
  end

  class Config
    attr_accessor :dummy
  end
end
