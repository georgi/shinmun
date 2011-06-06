module Shinmun
  ROOT = File.expand_path(File.dirname(__FILE__) + '/../..')

  class Blog < Kontrol::Application
    include Helpers

    attr_accessor :config
    attr_reader :posts, :pages, :posts_by_date, :posts_by_category, :posts_by_tag

    %w[ base_path title description language author categories ].each do |name|
      define_method(name) { @config[name.to_sym] }
    end

    # Initialize the blog
    def initialize(path)
      super

      @config = {}
      @templates = {}

      load_posts
      load_pages
      sort_posts
    end

    def self.init(path)
      path = File.expand_path(path)
      Dir.mkdir(path)

      FileUtils.cp_r "#{ROOT}/public", path
      FileUtils.cp_r "#{ROOT}/templates", path
      FileUtils.cp "#{ROOT}/config.ru", path

      Dir.mkdir("#{path}/posts")
      Dir.mkdir("#{path}/pages")
      File.open("#{path}/Gemfile") do |io|
        io.puts('gem "shinmun"')
      end
    end

    def render(name, vars = {})
      super(name, vars.merge(:blog => self))
    end

    def reload_changed_files
      (@posts + @pages.values).each do |post|
        if post.changed?
          post.load
          @changed = true
        end
      end

      sort_posts if @changed
    end

    def call(env)
      reload_changed_files # if ENV['RACK_ENV'] != 'production'
      super
    end

    def load_pages
      @pages = {}

      Dir["#{ path }/pages/*.md"].each do |file|
        page = Post.new(:file => file)
        @pages[page.name] = page
      end
    end

    def load_posts
      @posts = Dir["#{ path }/posts/**/*.md"].map do |file|
        Post.new(:file => file)
      end
    end
    
    def sort_posts      
      @posts = @posts.sort_by { |post| post.date.to_s }.reverse
      
      @posts_by_category = Hash.new do |hash, category|
        hash[category] = []
      end
      
      @posts_by_tag = Hash.new do |hash, tag|
        hash[tag] = []
      end

      @posts_by_date = Hash.new do |hash, year|
        hash[year] = Hash.new do |hash_months, month|
          hash_months[month] = Hash.new
        end
      end
      
      @posts.each do |post|
        post.tag_list.each { |tag| @posts_by_tag[tag] << post }
        @posts_by_category[post.category] << post if post.category
        @posts_by_date[post.year][post.month][post.name] = post
      end
    end

    def url
      "http://#{request.host}"
    end

    def symbolize_keys(hash)      
      hash.inject({}) do |h, (k, v)|
        h[k.to_sym] = v
        h
      end
    end

    def find_category(permalink)
      categories.find { |name| urlify(name) == permalink }
    end

    # Return all posts with any of given tags.
    def posts_with_tags(tags)
      return [] if tags.nil? or tags.empty?
      tags = tags.split(',').map { |t| t.strip } if tags.is_a?(String)

      tags.map { |tag| posts_by_tag[tag] }.flatten.uniq
    end

    # Return all archives as tuples of [year, month, posts].
    def archives
      posts.map { |p| [p.year, p.month] }.uniq.sort
    end

  end
  
end
