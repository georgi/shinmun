module Shinmun

  class Builder

    attr_reader :blog

    def initialize(blog, &block)
      @blog = blog
      @ins = []
      instance_eval(&block) if block_given?
    end

    def use(middleware, *args, &block)
      @ins << if block_given?
        lambda { |app| middleware.new(app, *args, &block) }
      else
        lambda { |app| middleware.new(app, *args) }
      end
    end

    def controller(method, &block)
      controller = Controller.new(blog)
      singleton = class << controller; self; end
      singleton.send(:define_method, method, &block)
      controller
    end

    def run(app)
      if app.is_a?(Class)
        @ins << lambda { |env| app.new(blog).call(env) }
      else
        @ins << app
      end
    end

    def get(pattern, options = {}, &block)
      map(pattern, controller(:get, &block), options.merge(:method => 'GET'))
    end

    def put(pattern, options = {}, &block)
      map(pattern, controller(:put, &block), options.merge(:method => 'PUT'))
    end

    def post(pattern, options = {}, &block)
      map(pattern, controller(:post, &block), options.merge(:method => 'POST'))
    end

    def delete(pattern, options = {}, &block)
      map(pattern, controller(:delete, &block), options.merge(:method => 'DELETE'))
    end

    def url_map
      @ins << URLMap.new unless @ins.last.is_a?(URLMap)
      @ins.last
    end

    def map(pattern, *args, &block)      
      options = args.last.is_a?(Hash) ? args.pop : {}
      app = block ? Builder.new(blog, &block).to_app : args.pop
      url_map.map(pattern, app, options)
    end

    def to_app
      @ins[0...-1].reverse.inject(@ins.last) { |a, e| e.call(a) }
    end

    def call(env)
      to_app.call(env)
    end

  end

end
