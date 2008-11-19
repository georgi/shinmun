module Shinmun

  class URLMap

    def initialize
      @routing = []
    end

    def map(pattern, app, options = {})
      params = []
      pattern = pattern.gsub(/[:*][_a-zA-Z0-9]+/) do |name|
        params << name[1..-1]
        case name[0, 1]
        when ':' : '([-_.a-zA-Z0-9]*)'
        when '*' : '(.*)'
        end
      end
      @routing << [/#{pattern}/, app, params, options]
    end

    def options_match(env, options)
      return options[:method].match(env['REQUEST_METHOD']) if options[:method]
      return true
    end

    def match(env, pattern, app, params, options)
      path = env["PATH_INFO"].to_s.squeeze("/")
      match = pattern.match(path)

      if match and options_match(env, options)
        env['shinmun.params'] = {}
        params.each_with_index do |name, index|
          env['shinmun.params'][name] = match[index + 1].split('.').first
        end
        return app
      end
    end

    def call(env)
      for route in @routing
        app = match(env, *route) and return app.call(env)
      end

      [404, {"Content-Type" => "text/plain"}, ["Not Found: #{path}"]]
    end

  end

end
