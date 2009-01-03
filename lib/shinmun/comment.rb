module Shinmun

  class Comment

    attr_accessor :time, :name, :email, :website, :text

    def initialize(attributes)
      attributes.each do |k, v|
        send("#{k}=", v) if respond_to?("#{k}=")
      end

      self.time ||= Time.now
    end

  end

end
