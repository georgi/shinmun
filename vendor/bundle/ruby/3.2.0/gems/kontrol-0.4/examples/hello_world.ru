require 'kontrol'

class HelloWorld < Kontrol::Application
  
  def time
    Time.now.strftime "%H:%M:%S"
  end

  map do
    root '/' do
      text "<h1>Hello World at #{time}</h1>"
    end
  end
end

run HelloWorld.new
