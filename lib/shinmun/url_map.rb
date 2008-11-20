module Shinmun

  class URLMap

    def initialize
      @routing = []
    end

    def map(pattern, app, options = {})
      params = []
      pattern = pattern.gsub(/[:,][_a-zA-Z0-9]+/) do |name|
        params << name[1..-1]
        case name[0, 1]
        when ':' : '([-_.a-zA-Z0-9]*)'
        when ',' : '(.*)'
        end
      end
      @routing << [/^#{pattern}$/, app, params, options]
    end

    OPTION_MAPPING = {
      :method => 'REQUEST_METHOD',
      :format => 'kontrol.format'
    }

    def options_match(env, options)
      options.all? { |name, pattern| pattern.match(env[OPTION_MAPPING[name]]) }
    end

    def match(env, pattern, app, params, options)            
      unless env['kontrol.path']
        env['kontrol.path'], env['kontrol.format'] = env['PATH_INFO'].split('.') 
        env['kontrol.params'] = {}
      end
      
      match = pattern.match(env['kontrol.path'])

      if match and options_match(env, options)
        params.each_with_index do |name, index|
          env['kontrol.params'][name] = match[index + 1]
        end
        return app
      end
    end

    def call(env)
      for route in @routing
        app = match(env, *route) and return app.call(env)
      end

      [404, {"Content-Type" => "text/plain"}, ["Not Found: #{env['REQUEST_URI']}"]]
    end

  end

end
