module Shinmun

  module Helpers
  end

  # This class renders an ERB template for a set of attributes, which
  # are accessible as instance variables.
  class Template
    include Helpers

    attr_reader :erb, :blog

    # Initialize this template with an ERB instance.
    def initialize(erb, file)
      @erb = erb
      @file = file
    end    

    # Set instance variable for this template.
    def set_variables(vars)
      for name, value in vars
        instance_variable_set("@#{name}", value)
      end
      self
    end

    # Render this template.
    def render
      @erb.result(binding)
    rescue => e
      e.backtrace.each do |s|
        s.gsub!('(erb)', @file)
      end
      raise e
    end

  end

end
