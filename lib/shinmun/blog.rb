module Shinmun

  class Blog < Kontrol::Application
    
    EXAMPLE_DIR = File.expand_path(File.dirname(__FILE__) + '/../../example')

    include Helpers

    attr_reader :aggregations, :categories, :comments, :repo

    %w[ assets comments config posts pages ].each do |name|
      define_method(name) { store.root.tree(name) }
    end

    %w[ title description language author url base_path categories ].each do |name|
      define_method(name) { config['blog.yml'][name] }
    end

    # Initialize the blog
    def initialize(path)
      super

      @aggregations = {}
      @repo = Grit::Repo.new(path)
      
      Thread.start do
        loop do
          load_aggregations
          sleep 300
        end
      end
    end

    def self.init(name)
      Dir.mkdir name      
      Dir.chdir name
      FileUtils.cp_r EXAMPLE_DIR + '/.', '.'
      `git init`
      `git add .`
      `git commit -m 'init'`
    end

    def load_aggregations
      config['aggregations.yml'].to_a.each do |c|
        aggregations[c['name']] = Object.const_get(c['class']).new(c['url'])
      end
    end

    def posts_by_date
      posts.sort_by { |post| post.date.to_s }.reverse
    end

    def recent_posts
      posts_by_date[0, 20]
    end

    # Return all posts for a given month.
    def posts_for_month(year, month)
      posts_by_date.select { |p| p.year == year and p.month == month }
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

    def tree(post)
      post.date ? posts.tree(post.year).tree(post.month) : pages
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

    # Create a new post with given attributes.
    def create_post(atts)
      post = Post.new(atts)
      transaction "create '#{post.title}'" do
        store[post.path] = post
      end
    end

    def update_post(post, data)
      transaction "update '#{post.title}'" do
        store.delete(post.path)
        post.parse data
        store[post.path] = post
      end
    end

    def delete_post(post)
      transaction "delete '#{post.title}'" do
        store.delete(post.path)
      end
    end

    def comments_for(path)
      comments[path + '.yml'] || []
    end

    def post_comment(path, params)
      transaction "new comment for '#{path}'" do
        comments[path + '.yml'] = comments[path + '.yml'].to_a + [ Comment.new(params) ]
      end
    end

    def find_page(name)
      pages.find { |p| p.name == name }
    end

    def find_post(year, month, name)
      tree = posts[year, month] and tree.find { |p| p.name == name }
    end

    def find_category(permalink)
      name = categories.find { |name| urlify(name) == permalink } or raise "category not found"
      posts = self.posts.select { |p| p.category == name }.sort_by { |p| p.date }.reverse
      { :name => name, :posts => posts, :permalink => permalink }
    end

    def write(file, template, vars={})
      file = "public/#{base_path}/#{file}"
      FileUtils.mkdir_p(File.dirname(file))
      open(file, 'wb') do |io|
        io << render(template, vars)
      end
    end

    def render(name, vars = {})
      super(name, vars.merge(:blog => self))
    end

    def call(env)
      templates['helpers.rb']
      super
    end
    
  end  
  
end
