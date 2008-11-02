module Shinmun

  def self.start_server
    require 'shinmun/controller'
    require 'shinmun/admin_controller'

    blog = Shinmun::Blog.new

    app = Rack::Builder.new do
      use Rack::ShowExceptions
      use Rack::Reloader
      
      map "/" do
        run Shinmun::RackAdapter.new(blog)
      end      

      map "/admin_controller" do
        use Rack::CommonLogger
        run Shinmun::AdminController.new(blog)
      end

      for dir in %w{admin stylesheets images javascripts}
        map "/#{dir}" do
          run Rack::File.new("public/#{dir}")
        end
      end

    end.to_app

    Rack::Handler::Mongrel.run(app, :Port => 3000)
  end

end

