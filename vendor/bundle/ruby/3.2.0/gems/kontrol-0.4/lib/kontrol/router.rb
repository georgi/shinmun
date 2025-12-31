module Kontrol

  class Router
    
    def initialize(&block)
      @routes = []
      @map = {}

      instance_eval(&block) if block
    end

    def __find__(name)
      @map[name.to_sym]
    end

    def __recognize__(request)
      @routes.each do |route|
        if match = route.recognize(request)
          return route, match
        end
      end
      
      return nil
    end

    def method_missing(name, pattern, *args, &block)
      route = Route.new(name, pattern, args.first, block)
      
      @routes << route
      @map[name] = route
    end

  end

end
