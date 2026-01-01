module Shinmun
  ROOT = File.expand_path(File.dirname(__FILE__) + '/../..')

  class Blog < Kontrol::Application
    include Helpers

    attr_accessor :config
    attr_reader :posts, :pages, :posts_by_date, :posts_by_category, :posts_by_tag

    %w[ title description language author categories ].each do |name|
      define_method(name) { @config[name.to_sym] }
    end

    # Returns custom variables from config (for use in templates)
    def variables
      @config[:variables] || {}
    end

    # Returns the base path for the blog (defaults to empty string for root deployment)
    def base_path
      @config[:base_path] || ''
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
      File.open("#{path}/Gemfile", "w") do |io|
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
      published_posts.map { |p| [p.year, p.month] }.uniq.sort
    end

    # Return all published (non-draft) posts
    def published_posts
      @posts.reject(&:draft?)
    end

    # Return related posts based on shared tags and category
    # Excludes the given post and returns up to `limit` related posts
    def related_posts(post, limit: 5)
      return [] unless post
      
      scores = {}
      
      # Score based on shared tags (2 points per shared tag)
      post.tag_list.each do |tag|
        posts_by_tag[tag].each do |related|
          # Use object_id comparison for posts without files, otherwise use ==
          is_same = post.file ? (related == post) : (related.object_id == post.object_id)
          next if is_same || related.draft?
          scores[related] ||= 0
          scores[related] += 2
        end
      end
      
      # Score based on same category (3 points)
      if post.category
        posts_by_category[post.category].each do |related|
          is_same = post.file ? (related == post) : (related.object_id == post.object_id)
          next if is_same || related.draft?
          scores[related] ||= 0
          scores[related] += 3
        end
      end
      
      # Sort by score (descending) then by date (descending)
      scores.sort_by { |p, score| [-score, -(p.date.to_s.gsub('-', '').to_i)] }
            .first(limit)
            .map(&:first)
    end

    # Return recent posts (for sidebar widgets)
    def recent_posts(limit: 5)
      published_posts.first(limit)
    end

    # Return all tags with their post counts
    def tags_with_counts
      published_posts.flat_map(&:tag_list)
                    .group_by(&:itself)
                    .transform_values(&:count)
                    .sort_by { |tag, count| [-count, tag] }
    end

  end
  
end
