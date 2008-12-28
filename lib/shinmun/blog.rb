module Shinmun

  class Blog < Kontrol::Application

    EXAMPLE_DIR = File.expand_path(File.dirname(__FILE__) + '/../../example')

    include Helpers

    attr_reader :posts, :pages, :aggregations, :categories, :comments
    
    config_reader 'blog.yml', :title, :description, :language, :author, :url, :repository, :base_path, :categories

    # Initialize the blog
    def initialize(&block)
      super

      @aggregations = {}
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

    def posts
      store['posts'] ||= GitStore::Tree.new
    end

    def pages
      store['pages'] ||= GitStore::Tree.new
    end

    def comments
      store['comments'] ||= GitStore::Tree.new
    end
    
    def load_aggregations
      config['aggregations.yml'].to_a.each do |c|
        aggregations[c['name']] = Object.const_get(c['class']).new(c['url'])
      end
    end

    def recent_posts
      posts.sort_by { |post| post.date }.reverse[0, 20]
    end

    def posts_by_date      
      posts.sort_by { |post| post.date }.reverse
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

    def tree_for(post)
      if post.date
        (posts[post.year] ||= GitStore::Tree.new)[post.month] ||= GitStore::Tree.new
      else
        pages
      end      
    end

    def symbolize_keys(hash)      
      hash.inject({}) do |h, (k, v)|
        h[k.to_sym] = v
        h
      end
    end

    def commit(message)
      store.commit(message)
    end

    # Create a new post with given attributes.
    def create_post(atts = {})
      atts = { :type => 'md' }.merge(symbolize_keys(atts))
      title = atts[:title] or raise "no title given"
      atts[:name] ||= urlify(title)
      atts[:date] ||= Date.today
      post = Post.new(atts)
      tree_for(post)[post.filename] = post
      commit "created `#{post.title}`"
      tree_for(post)[post.filename]
    end

    def update_post(post, data)
      tree_for(post).delete(post.filename)
      post.parse data
      tree_for(post)[post.filename] = post
      commit "updated `#{post.title}`"
      post
    end

    def delete_post(post)
      tree_for(post).delete(post.filename)      
      commit "deleted `#{post.title}`"
    end

    def comments_for(post)
      comments["#{post.path}.yml"] ||= []
    end

    def post_comment(post, params)
      comments_for(post) << Comment.new(params)
      commit "new comment for `#{post.title}`"
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

    def find_by_path(path)
      posts.find { |p| p.path == path } or pages.find { |p| p.path == path }
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
    
  end
  
end
