require 'rack'

module Shinmun

  class RackAdapter

    def initialize(blog)
      @blog = blog
      @routing = []

      map /\.rss$/, FeedController
      map /^\/\d\d\d\d\/\d+/, PostController
      map /^\/categories/, CategoryController
      map /^\/comments/, CommentsController
      map //, PageController
    end

    def map(pattern, controller)
      @routing << [pattern, controller]
    end

    def call(env)
      request = Rack::Request.new(env)
      response = Rack::Response.new

      @blog.reload

      klass = find_controller(request.path_info)

      controller = klass.new(@blog, request, response)
      controller.handle_request

      response.status ||= 200
      response.finish
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
    end
  end

  class PageController < Controller
    def get
      if path.empty?
        blog.render_index_page
      else
        page = blog.find_page(path) or raise "#{path} not found"
        blog.render_page(page)
      end
    end
  end

  class PostController < PageController
    def get
      if post = blog.find_post(path)
        blog.render_post(post)
      else
        year, month, = path.split('/')
        blog.render_month(year.to_i, month.to_i)
      end
    end
  end

  class FeedController < Controller
    def get
      path_list = path.split('/')
      case path_list[0]
      when 'categories'
        category = blog.find_category(path_list[1].chomp('.rss'))
        blog.render_category_feed(category)
      when 'index'
        blog.render_index_feed
      end
    end
  end

  class CategoryController < Controller
    def get
      category = blog.find_category(path.split('/')[1].chomp('.html'))
      blog.render_category(category)
    end
  end

  class CommentsController < Controller

    def post
      params['path'].include?('..') and raise 'invalid path'

      comment = Comment.new(:time => Time.now,
                            :name => params['name'],
                            :email => params['email'],
                            :website => params['website'],
                            :text => params['text'])

      if params['preview'] == 'true'
        blog.render_comments([comment])
      else
        Comment.write(params['path'], comment)
        blog.render_comments(Comment.read(params['path']))
      end
    end

  end

end

