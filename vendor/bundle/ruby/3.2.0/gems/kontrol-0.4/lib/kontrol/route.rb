module Kontrol

  class Route
    attr_accessor :name, :pattern, :options, :block
    
    def initialize(name, pattern, options, block)
      @name = name
      @pattern = pattern
      @block = block
      @options = options || {}
      @format = pattern.gsub(/\(.*?\)/, '%s')
      @regexp = /^#{pattern}/
    end

    def recognize(request)
      match = request.path_info.match(@regexp)
      valid = @options.all? { |key, val| request.send(key).match(val) }

      return match if match and valid
    end

    def generate(*args)
      @format % args.map { |arg|
        arg.respond_to?(:to_param) ? arg.to_param : arg.to_s
      }
    end
    
  end

end
