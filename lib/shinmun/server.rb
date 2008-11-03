module Shinmun

  def self.start_server
    require 'shinmun/controller'
    require 'shinmun/admin_controller'

    blog = Shinmun::Blog.new

    app = Rack::Builder.new do
      use Rack::ShowExceptions
      use Rack::Reloader
      
      map "/#{blog.base_path}" do
        run Shinmun::RackAdapter.new(blog)
      end      

      map '/admin' do
        run Rack::File.new('admin')
      end

      map "/admin_controller" do
        use Rack::CommonLogger
        run Shinmun::AdminController.new(blog)
      end

      Dir.chdir('assets') do
        Dir['*'].each do |file|
          map "/#{file}" do
            run Rack::File.new("assets/#{file}")
          end
        end
      end

    end.to_app

    Rack::Handler::Mongrel.run(app, :Port => 3000)
  end

end

