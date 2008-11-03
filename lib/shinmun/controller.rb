require 'rack'

module Shinmun

  class RackAdapter

    def initialize(blog)
      @blog = blog
      @routing = [[/\.rss$/, FeedController],
                  [/^\/\d\d\d\d\/\d+\//, PostController],
                  [/^\/categories/, CategoryController],
                  [//, PageController]]
    end

    def call(env)
      request = Rack::Request.new(env)
      response = Rack::Response.new

      @blog.reload
      @blog.pack_assets

      klass = find_controller(request.path_info)
      controller = klass.new(@blog, request, response)
      controller.handle_request
    end

    def find_controller(path)
      for pattern, klass in @routing
        return klass if pattern.match(path)
      end
    end

  end

  class Controller
    attr_reader :blog, :request, :response, :path, :extname

    def initialize(blog, request, response)
      @blog = blog
      @request = request
      @response = response
      @extname = File.extname(request.path_info)
      @path = request.path_info[1..-1].chomp(@extname)
    end

    def params
      request.params
    end

    def redirect_to(location)
      response.headers["Location"] = location
      response.status = 302
    end

    def handle_request
      action = request.request_method.downcase

      response.body = send(action) if self.class.public_instance_methods.include?(action)
      response.status ||= 200
      response.finish
    end
  end

  class PageController < Controller
    def get
      page = blog.find_page(path.empty? ? 'index' : path) or raise "#{path} not found"
      blog.render_page(page)
    end
  end

  class PostController < PageController
    def get
      year, month, file = path.split('/')
      if file == '' or file == 'index'
        blog.render_month(year.to_i, month.to_i)
      else
        post = blog.find_post(path) or raise "#{path} not found"
        blog.render_post(post)
      end      
    end
  end

  class FeedController < Controller
    def get
      path_list = path.split('/')
      case path_list[0]
      when 'categories'
        category = blog.find_category(path_list[1])
        blog.render_category_feed(category)
      when 'index'
        blog.render_index_feed
      end
    end
  end

  class CategoryController < Controller
    def get
      category = blog.find_category(path.split('/')[1])
      blog.render_category(category)
    end
  end

end

