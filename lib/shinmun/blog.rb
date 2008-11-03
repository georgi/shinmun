module Shinmun

  # This class represents a blog. You need to provide a source
  # directory and the meta file `blog.yml` which defines some variables.
  # Example for `blog.yml`:
  #    blog_title: Matthias Georgi
  #    blog_description: Webdev, Gamedev, Interaction Design
  #    blog_language: en
  #    blog_author: Matthias Georgi
  #    blog_url: http://www.matthias-georgi.de
  #    categories:
  #      - Ruby
  #      - Emacs
  class Blog

    FILE_PATTERN = '**/*.{md,tt,html,rhtml}'

    attr_reader :meta, :posts, :pages
    attr_reader :base_path, :images_path, :javascripts_path, :stylesheets_path, :repository

    def initialize
      @uuid = UUID.new
      @templates = {}
      reload
    end

    # Read config and all posts from disk.
    def reload
      @meta = YAML.load(File.read('config/blog.yml'))
      @base_path = meta['base_path'] || ''
      @images_path = meta['images_path'] || 'images'
      @javascripts_path = meta['javascripts_path'] || 'javascripts'
      @stylesheets_path = meta['stylesheets_path'] || 'stylesheets'
      @repository = meta['blog_repository']

      Dir.chdir('posts') do
        @posts = Dir[FILE_PATTERN].map { |path| Post.new(self, path).load }
        @posts = @posts.sort_by { |post| post.date }.reverse
      end

      Dir.chdir('pages') do
        @pages = Dir[FILE_PATTERN].map { |path| Post.new(self, path).load }
      end

      load 'templates/helpers.rb' if File.exist?('templates/helpers.rb')
    end

    def public_paths
      ['admin', images_path, stylesheets_path, javascripts_path]
    end

    def push
      system "rsync -avz public/ #{repository}"
    end

    def url
      @meta['blog_url']
    end

    def categories
      meta['categories']
    end

    def compress(filename)
      require 'packr'
      src = File.read(filename)
      name, ext = filename.split('.')
      min = name + '.min.' + ext
      if !File.exist?(min) or File.mtime(filename) > File.mtime(min)
        open(min, "wb") do |file|
          file << Packr.pack(src)
        end
      end
      File.read(min)
    end

    def pack_javascripts
      File.open("assets/#{javascripts_path}/all.js", "wb") do |io|
        for file in meta['pack_javascripts']
          io << compress("assets/#{javascripts_path}/#{file.strip}.js") << "\n\n"
        end
      end
    end

    def pack_stylesheets
      File.open("assets/#{stylesheets_path}/all.css", "wb") do |io|
        for file in meta['pack_stylesheets']
          io << File.read("assets/#{stylesheets_path}/#{file.strip}.css") << "\n\n"
        end
      end
    end

    def copy_assets
      FileUtils.cp_r 'assets/.', 'public'
    end
    
    def pack_assets
      pack_javascripts if meta['pack_javascripts']
      pack_stylesheets if meta['pack_stylesheets']
    end

    # Write a file to output directory.
    def write_file(path, data)
      FileUtils.mkdir_p("public/#{base_path}/#{File.dirname path}")
      filepath = "public/#{base_path}/#{path}"
      open(filepath, 'wb') do |file|
        file << data
      end    
    end

    # Return all posts for a given month.
    def posts_for_month(year, month)
      posts.select { |p| p.year == year and p.month == month }
    end

    # Return all posts in given category.
    def posts_for_category(category)
      posts.select { |p| p.category == category }
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

    def create_post(title)
      date = Date.today
      name = Shinmun.urlify(title)
      path = "#{date.year}/#{date.month}/#{name}.md"

      if File.exist?(file)
        raise "#{file} exists"
      else
        post = Post.new(self, path)
        post.title = title
        post.head = {
          'date' => date,
          'guid' => @uuid.generate,
          'category' => ''
        }
        post.save
      end
    end

    def find_page(path)
      pages.find { |p| p.path == path }
    end

    def find_post(path)
      posts.find { |p| p.path == path }
    end

    def find_category(category)
      category = Shinmun.urlify(category)
      categories.find { |c| Shinmun.urlify(c) == category }
    end

    # Return template variables as hash.
    def variables
      meta.merge(:posts => posts, 
                 :months => months,
                 :categories => categories)
    end

    # Read and cache template file.
    def template(name)
      ERB.new(File.read("templates/#{name}"))
    end

    # Render template with given variables.
    def render_template(name, vars)
      template = Template.new(template(name), self)
      template.set_variables(vars)
      template.render
    end

    def render_layout(vars)
      render_template("layout.rhtml", variables.merge(vars))
    end

    # Render named template and insert into layout with given variables.
    def render(name, vars)
      vars = variables.merge(vars)
      render_layout(vars.merge(:content => render_template(name, vars)))
    end

    def render_post(post)
      render('post.rhtml', post.variables.merge(:header => post.category))
    end

    def render_page(page)
      render_layout(page.variables.merge(:content => page.body_html))
    end

    def render_category(category)
      posts = posts_for_category(category)
      render("list.rhtml",  
             :header => category,
             :category => category, 
             :posts => posts)
    end

    def render_month(year, month)
      path = "#{year}/#{month}"
      month_name = Date::MONTHNAMES[month]
      posts = posts_for_month(year, month)
      render("list.rhtml", 
             :header => "#{month_name} #{year}",
             :year => year, 
             :month => month_name, 
             :posts => posts)
    end

    def render_index_feed
      render_template("feed.rxml", variables)
    end

    def render_category_feed(category)
      posts = posts_for_category(category)
      vars = variable.merge(:category => category, 
                            :posts => posts)
      render_template("feed.rxml", vars)
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
        write_file("categories/#{Shinmun.urlify category}.html", render_category(category))
      end
    end

    # Write rss feeds for index page and categories.
    def write_feeds
      write_file("index.rss", render_index_feed)      
      for category in categories
        write_file("categories/#{Shinmun.urlify category}.rss", render_category(category))
      end
    end

    def write_all
      pack_assets
      copy_assets

      write_pages
      write_posts
      write_archives
      write_categories
      write_feeds      
    end

  end

end
