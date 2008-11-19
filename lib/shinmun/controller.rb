module Shinmun

  class Controller
    attr_reader :blog, :request, :response, :path_info, :format, :params, :action

    def initialize(blog)
      @blog = blog
    end

    def action_allowed?(action)
      (self.class.public_instance_methods + singleton_methods).include?(action)
    end

    def call(env)
      blog.reload

      @request = Rack::Request.new(env)
      @response = Rack::Response.new(env)
      @path_info, @format = request.path_info.split('.')
      @params = request.params.merge(env['shinmun.params'])
      @action = params['action'] || request.request_method.downcase

      Shinmun.log.debug "#{request.request_method} #{path_info} #{params.inspect}"
      
      if action_allowed?(action)
        result = send(action) 
      else
        raise "action `#{action}' is not supported"
      end
      
      if result.is_a?(Array)
        status, header, body = result
        response.status = status
        response.body = body
        response.header.merge!(header)
      else
        response.body = result
        response.status ||= 200
      end

      response.finish
    end
  end

end

