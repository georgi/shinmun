require 'digest/sha1'

module Kontrol

  class Application
    include Helpers

    attr_reader :path

    class << self
      attr_accessor :router
      
      def map(&block)
        @router = Router.new(&block)
      end
    end
    
    def initialize(path = '.')
      @path = File.expand_path(path)      
    end

    def load_template(file)
      @templates[file] ||= Template.new(self, "#{self.path}/templates/#{file}")
    end
    
    # Render template with given variables.
    def render_template(file, variables)
      template = load_template(file) or raise "template not found: #{path}"
      template.render(variables)
    end

    # Render named template and insert into layout with given variables.
    def render(name, options = {})
      options = options.merge(:request => request, :params => params)
      content = render_template(name, options)
      layout = options.delete(:layout)
      
      if name[0, 1] == '_'
        return content
        
      elsif layout == false
        response.body = content
      else
        options.merge!(:content => content)
        response.body = render_template(layout || "layout.rhtml", options)
      end

      response['Content-Length'] = response.body.size.to_s
    end

    def etag(string)
      Digest::SHA1.hexdigest(string)
    end

    def if_modified_since(time)
      date = time.respond_to?(:httpdate) ? time.httpdate : time
      response['Last-Modified'] = date
      
      if request.env['HTTP_IF_MODIFIED_SINCE'] == date
        response.status = 304
      else
        yield        
      end
    end
    
    def if_none_match(etag)
      response['Etag'] = etag
      if request.env['HTTP_IF_NONE_MATCH'] == etag
        response.status = 304
      else
        yield
      end
    end
    
    def request ; Thread.current['request']   end
    def response; Thread.current['response']  end
    def params  ; request.params              end
    def cookies ; request.cookies             end
    def session ; request.env['rack.session'] end
    def post?   ; request.post?               end
    def get?    ; request.get?                end
    def put?    ; request.put?                end
    def delete? ; request.delete?             end
    def post    ; request.post? and yield     end
    def get     ; request.get? and yield      end
    def put     ; request.put? and yield      end
    def delete  ; request.delete? and yield   end

    def text(s)
      response.body = s
      response['Content-Length'] = response.body.size.to_s
    end

    def redirect(path)
      response['Location'] = path
      response.status = 301
    end

    def guess_content_type
      ext = File.extname(request.path_info)[1..-1]
      MIME_TYPES[ext] || 'text/html'
    end

    def router
      self.class.router
    end

    def call(env)
      Thread.current['request'] = Rack::Request.new(env)
      Thread.current['response'] = Rack::Response.new([], 200, { 'Content-Type' => '' })

      route, match = router.__recognize__(request)

      if route
        method = "process_#{route.name}"
        self.class.send(:define_method, method, &route.block)
        send(method, *match.to_a[1..-1])
      else
        response.body = "<h1>404 - Page Not Found</h1>"
        response['Content-Length'] = response.body.size.to_s
        response.status = 404
      end

      response['Content-Type'] = guess_content_type if response['Content-Type'].empty?
      response.finish
    end

    def inspect
      "#<#{self.class.name} @path=#{path}>"
    end

    def respond_to?(name)
      if match = name.to_s.match(/^(.*)_path$/)
        router.__find__(match[1])
      else
        super
      end
    end

    def method_missing(name, *args, &block)
      if match = name.to_s.match(/^(.*)_path$/)
        if route = router.__find__(match[1])
          route.generate(*args)
        else
          super
        end
      else
        super
      end
    end
    
  end

end

