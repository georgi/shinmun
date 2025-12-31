module Kontrol

  class View
    
    def initialize(variables)
      variables.each do |k, v|
        instance_variable_set "@#{k}", v
      end
    end
    
    def __binding__
      binding
    end

    def method_missing(id, *args, &block)
      if @application.respond_to?(id)
        @application.send(id, *args, &block)
      else      
        super
      end
    end
  end

  # This class renders an ERB template for a set of attributes, which
  # are accessible as instance variables.
  class Template
    include Helpers

    attr_reader :file

    def initialize(app, file)
      @app = app
      @file = file
      
      load
    end

    def load
      @mtime = File.mtime(file)
      @erb = ERB.new(File.read(file))
    end
    
    def changed?
      File.mtime(@file) != @mtime
    end
    
    def render(variables)
      load if ENV['RACK_ENV'] != 'production' and changed?
      
      @erb.result(View.new(variables.merge(:application => @app)).__binding__)

    rescue => e
      e.backtrace.each do |s|
        s.gsub!('(erb)', file)
      end
      raise e
    end

  end

end
