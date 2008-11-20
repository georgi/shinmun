module Shinmun

  def self.log
    @log ||= Logger.new(STDERR)
  end

  class Blog

    # Define reader methods for configuration.
    def self.config_reader(file, *names)
      names.each do |name|
        name = name.to_s        
        define_method(name) { @config[file][name] }
      end
    end

    attr_reader :root, :posts, :pages, :aggregations
    
    config_reader 'config/assets.yml', :javascript_files, :stylesheet_files, :images_path, :javascripts_path, :stylesheets_path
    config_reader 'config/blog.yml', :title, :description, :language, :author, :url, :repository, :base_path
    config_reader 'config/categories.yml', :categories

    # Initialize the blog, load the config file and write the index files.
    def initialize
      @config = Cache.new do |file|
        YAML.load(File.read(file))
      end

      @stylesheets = Cache.new

      @templates = Cache.new do |file|
        ERB.new(File.read(file))
      end

      @javascripts = Cache.new do |file|
        script = File.read(file)
        script = Packr.pack(script) if defined?(Packr)
        "/* #{file} */\n #{script}\n"
      end

      @posts_cache = Cache.new do |file|
        Post.new(:filename => file).load
      end

      @pages_cache = Cache.new do |file|
        Post.new(:filename => file).load
      end

      @config.load('config/aggregations.yml')
      @config.load('config/assets.yml')
      @config.load('config/blog.yml')
      @config.load('config/categories.yml')

      @aggregations = {}

      load_pages
      load_posts

      Thread.start do
        loop do
          load_aggregations
          sleep 300
        end
      end

      Thread.start do
        loop do
          sleep 1
          load_pages
          load_posts
        end
      end

    end

    def load_pages
      Dir['pages/**/*'].each do |file|
        @pages_cache.load(file) if File.file?(file) and file[-1, 1] != '~'
      end
    end

    def load_posts
      Dir['posts/**/*'].each do |file|
        @posts_cache.load(file) if File.file?(file) and file[-1, 1] != '~'
      end
    end

    def load_aggregations
      @config['config/aggregations.yml'].to_a.each do |c|
        @aggregations[c['name']] = Object.const_get(c['class']).new(c['url'])
      end
    end

    # Reload config, assets and posts.
    def reload
      if @config.dirty? || @templates.dirty?
        Shinmun.log.debug "config or templates changed -> reloading all ..."
        @config.reload!
        @templates.reload!
        @posts_cache.reload!
        @pages_cache.reload!        
      else
        @config.reload_dirty!
        @templates.reload_dirty!
        @posts_cache.reload_dirty!
        @pages_cache.reload_dirty!
      end

      @posts = @posts_cache.values.sort_by { |p| p.date }.reverse
      @pages = @pages_cache.values

      pack_javascripts if @javascripts.dirty? or @javascripts.empty?
      pack_stylesheets if @stylesheets.dirty? or @stylesheets.empty? 

      load 'templates/helpers.rb'
    end

    # Use rsync to synchronize the rendered blog to web server.
    def push
      Shinmun.log.debug "pushing public folder to #{repository} ..."
      system "rsync -avz public/ #{repository}"
    end

    def urlify(string)
      string.downcase.gsub(/[ -]+/, '-').gsub(/[^-a-z0-9_]+/, '')
    end

    # Compress the javascripts using PackR and write them to one file called 'all.js'.
    def pack_javascripts
      packed_file = "assets/#{javascripts_path}/all.js"
      Shinmun.log.debug "pack javascripts to #{packed_file} ..."
      @javascripts.reload_dirty!
      File.open(packed_file, "wb") do |io|
        for file in javascript_files
          io << @javascripts["assets/#{javascripts_path}/#{file.strip}.js"] << "\n\n"
        end
      end
    end

    # Pack the stylesheets and write them to one file called 'all.css'.
    def pack_stylesheets
      packed_file = "assets/#{stylesheets_path}/all.css"
      @stylesheets.reload_dirty!
      Shinmun.log.debug "pack stylesheets to #{packed_file} ..."
      File.open(packed_file, "wb") do |io|
        for file in stylesheet_files
          io << @stylesheets["assets/#{stylesheets_path}/#{file.strip}.css"] << "\n\n"
        end
      end
    end

    # Write a file to output directory.
    def write_file(path, data)
      file = "public/#{base_path}/#{path}"
      Shinmun.log.debug "writing #{file} ..."
      FileUtils.mkdir_p(File.dirname file)
      open(file, 'wb') do |io|
        io << data
      end    
    end

    # Return all posts for a given month.
    def posts_for_month(year, month)
      posts.select { |p| p.year == year and p.month == month }
    end

    # Return all posts in given category.
    def posts_for_category(category)
      name = category['name']
      posts.select { |p| p.category == name }
    end

    # Return all posts with any of given tags.
    def posts_with_tags(tags)
      return [] if tags.nil?
      tags = tags.split(',').map { |t| t.strip } if tags.is_a?(String)
      posts.select do |post|
        tags.any? do |tag| 
          post.tags.to_s.include?(tag) 
        end
      end
    end

    # Return all months as tuples of [year, month].
    def months
      posts.map { |p| [p.year, p.month] }.uniq.sort
    end

    # Create a new post with given title.
    def create_post(title)
      date = Date.today
      name = urlify(title)
      filename = "posts/#{date.year}/#{date.month}/#{name}.md"

      Shinmun.log.debug "creating post #{filename} ..."

      if File.exist?(filename)
        raise "#{filename} already exists"
      else
        Post.new(:filename => filename, :title => title, :date => date).save
      end
    end

    def normalize_path(path)
      if path[0, 1] == '/'
        path[1..-1] 
      else
        path
      end
    end

    def find_page(path)
      path = normalize_path(path)
      pages.find { |p| p.path == path }
    end

    def find_post(path)
      path = normalize_path(path)
      path = path[1..-1] if path[0, 1] == '/'
      posts.find { |p| p.path == path }
    end

    def find_category(category)
      category = urlify(category)
      categories.find { |c| urlify(c['name']) == category }
    end

    # Render template with given variables.
    def render_template(name, vars)
      template = Template.new(@templates["templates/#{name}"], name)
      template.set_variables(vars)
      template.render
    end

    def render_layout(vars)
      render_template("layout.rhtml", vars.merge(:blog => self))
    end

    # Render named template and insert into layout with given variables.
    def render(name, vars)
      render_layout(vars.merge(:content => render_template(name, vars.merge(:blog => self))))
    end

    # Render given post using the post template and the layout template.
    def render_post(post)
      post = find_post(post) if post.is_a?(String)
      post or raise "not found" 
      render('post.rhtml', post.variables.merge(:header => post.category))
    end

    # Render given page using only the layout template.
    def render_page(page)
      page = find_page(page) if page.is_a?(String)
      page or raise "not found"
      render_layout(page.variables.merge(:content => page.body_html))
    end

    def post_comment(params)
      path = params.delete('path')
      preview = params.delete('preview')
      comment = Comment.new(params)

      if preview == 'true'
        render_comments([comment])
      else
        Comment.write(path, comment)
        render_comments(Comment.read(path))
      end
    end

    # Render comments.
    def render_comments(comments)
      render_template('comments.rhtml', :comments => comments)
    end

    # Render index page using the index and the layout template.
    def render_index_page
      render('index.rhtml', 
             :header => 'Home',
             :posts => posts)
    end

    # Render the category summary for given category.
    def render_category(category)
      category = find_category(category) if category.is_a?(String)
      posts = posts_for_category(category)
      render("category.rhtml",  
             :header => category['name'],
             :category => category,
             :posts => posts)
    end

    # Render the archive summary for given month.
    def render_month(year, month)
      path = "#{year}/#{month}"
      month_name = Date::MONTHNAMES[month]
      posts = posts_for_month(year, month)
      render("month.rhtml", 
             :header => "#{month_name} #{year}",
             :year => year, 
             :month => month_name, 
             :posts => posts)
    end

    # Render index feed using the feed template.
    def render_index_feed
      render_template("index.rxml", 
                      :blog => self,
                      :posts => posts)
    end

    # Render category feed for given category using the feed template .
    def render_category_feed(category)
      category = find_category(category) if category.is_a?(String)
      render_template("category.rxml", 
                      :blog => self,
                      :category => category, 
                      :posts => posts_for_category(category))
    end

    def write_index_page
      write_file("index.html", render_index_page)
    end

    # Write all pages.
    def write_pages
      for page in pages
        write_file("#{page.path}.html", render_page(page))
      end
    end

    # Write all posts.
    def write_posts
      for post in posts
        write_file("#{post.path}.html", render_post(post))
      end
    end

    # Write archive summaries.
    def write_archives
      for year, month in months
        write_file("#{year}/#{month}/index.html", render_month(year, month))
      end
    end

    # Write category summaries.
    def write_categories
      for category in categories
        write_file("categories/#{urlify category['name']}.html", render_category(category))
      end
    end

    # Write rss feeds for index page and categories.
    def write_feeds
      write_file("index.rss", render_index_feed)      
      for category in categories
        write_file("categories/#{urlify category['name']}.rss", render_category_feed(category))
      end
    end

    # Render everything to public folder.
    def write_all
      load_aggregations
      reload
      FileUtils.cp_r 'assets/.', 'public'

      write_index_page
      write_pages
      write_posts
      write_archives
      write_categories
      write_feeds      
    end

    def route(rack, &block)
      builder = Shinmun::Builder.new(self, &block)

      rack.map "/#{base_path}" do
        run builder
      end
    end

  end

end
