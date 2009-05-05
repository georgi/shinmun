module Shinmun
  ROOT = File.expand_path(File.dirname(__FILE__) + '/../..')

  class Blog < Kontrol::Application
    include Helpers

    attr_accessor :config, :store, :posts, :pages

    %w[ base_path title description language author categories ].each do |name|
      define_method(name) { @config[name.to_sym] }
    end

    # Initialize the blog
    def initialize(path)
      super

      @config = {}
      @store = GitStore.new(path)
      @store.handler['md'] = PostHandler.new
      @store.handler['rhtml'] = ERBHandler.new
      @store.handler['rxml'] = ERBHandler.new
    end

    def self.init(path)
      path = File.expand_path(path)
      Dir.mkdir(path)

      FileUtils.cp_r "#{ROOT}/assets", path
      FileUtils.cp_r "#{ROOT}/templates", path
      FileUtils.cp "#{ROOT}/config.ru", path

      Dir.mkdir("#{path}/posts")
      Dir.mkdir("#{path}/pages")
      Dir.mkdir("#{path}/comments")
      Dir.mkdir("#{path}/public")

      FileUtils.ln_s("../assets", "#{path}/public/assets")

      Dir.chdir(path) do
        `git init`
        `git add .`
        `git commit -m 'init'`
      end
    end

    def load_template(file)
      store['templates/' + file]
    end

    def render(name, vars = {})
      super(name, vars.merge(:blog => self))
    end

    def pages      
      store.tree('pages').values
    end

    der posts
      store.tree('posts').values.sort_by { |post| post.date.to_s }.reverse
    end

    def call(env)
      store.load if store.changed?
      store.load(true) if ENV['RACK_ENV'] != 'production')
        
      super
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

    def transaction(message, &block)
      store.transaction(message, &block)
    end

    def post_file(post)
      'posts' + post_path(post) + '.' + post.type
    end

    def page_file(post)
      'pages' + page_path(post) + '.' + post.type
    end

    def comment_file(post)
      'comments/' + post_path(post) + '.yml'
    end

    def create_post(attr)
      post = Post.new(attr)
      path = post_file(post)

      transaction "create post `#{post.title}'" do
        store[path] = post
      end

      post
    end

    def create_page(attr)
      post = Post.new(attr)
      path = page_file(post)

      transaction "create page `#{post.title}'" do
        store[path] = post
      end

      post
    end

    def comments_for(post)
      store[comment_file post] || []
    end

    def create_comment(post, params)
      path = comment_file(post)
      comments = comments_for(post)
      comment = Comment.new(params)
      
      transaction "new comment for `#{post.title}'" do
        store[path] = comments + [comment]
      end
      
      comment
    end

    def find_page(name)
      pages.find { |p| p.name == name }
    end

    def find_post(year, month, name)
      posts.find { |p| p.year == year and p.month == month and p.name == name }
    end

    def find_category(permalink)
      name = categories.find { |name| urlify(name) == permalink }
      
      { :name => name,
        :posts => posts.select { |p| p.category == name },
        :permalink => permalink }
    end
    
    def recent_posts
      posts[0, 20]
    end

    # Return all posts for a given month.
    def posts_for_month(year, month)
      posts.select { |p| p.year == year and p.month == month }
    end
    
    # Return all posts with any of given tags.
    def posts_with_tags(tags)
      return [] if tags.nil? or tags.empty?
      tags = tags.split(',').map { |t| t.strip } if tags.is_a?(String)
      
      posts.select do |post|
        tags.any? do |tag| 
          post.tag_list.include?(tag)
        end
      end
    end

    # Return all archives as tuples of [year, month].
    def archives
      posts.map { |p| [p.year, p.month] }.uniq.sort
    end
    
  end  
  
end
