require 'fileutils'
require 'erb'
require 'yaml'
require 'uuid'
require 'bluecloth'

# A small and beautiful blog engine.
module Shinmun

  # Url encode a string. (taken from cgi.rb)
  def self.url_encode(string)
    string.gsub(/([^ a-zA-Z0-9_.-]+)/n) do
      '%' + $1.unpack('H2' * $1.size).join('%').upcase
    end.tr(' ', '+')
  end
  
  # This class represents an article or page.
  # A post has a header and body text.
  # Example:
  #     --- 
  #     category: Ruby
  #     guid: 7ad04f10-5dd6-012b-b53c-001a92975b89
  #     title: BlueCloth, a Markdown library
  #     tags: ruby, bluecloth, markdown
  #     date: 2008-09-05
  #      
  #     This is the summary, which is by definition the first paragraph of the
  #     article. The summary shows up in category listings or the index listing.  
  class Post

    attr_reader :blog, :path, :head, :src

    # Split up the source text into header and body.
    # Load the header as yaml document.
    def initialize(blog, path, src)
      match = src.match(/(.*?)\n\n(.*)/m)

      @blog = blog
      @path = path
      @head = YAML.load(match[1])
      @src = match[2]
    end

    # Generates the body from source text.
    def body
      @body ||= BlueCloth.new(@src).to_html
    end

    # Write the source data back to given io.
    def write(io)
      io << @head.to_yaml
      io << "\n"
      io << @src
    end

    # Generate an unique id.
    def generate_guid
      @head['guid'] = UUID.new
    end

    def title   ; @head['title']     end
    def date    ; @head['date']      end
    def tags    ; @head['tags']      end
    def category; @head['category']; end
    def guid    ; @head['guid']      end
    def year    ; date.year          end
    def month   ; date.month         end

    # Return the first paragraph of rendered html.
    def summary
      body.split("\n\n")[0]
    end

    # Return the first paragraph of source text.
    def text_summary
      src.split("\n\n")[0]
    end

    # Return doc root as relative path.
    def root
      slashes = path.count('/')
      if slashes > 0
        Array.new(slashes, '..').join('/') + '/'
      else
        ''
      end
    end
    
    # Return a hash of post attributes.
    def variables
      head.merge(:root => root, 
                 :header => category || title,
                 :body => body,
                 :link => link)
    end

    # Return absolute link to this post.
    def link
      "#{blog.meta['blog_url']}/#{path}.html"
    end

  end


  # This class renders an ERB template for a set of attributes, which
  # are accessible as instance variables.
  class Template

    attr_reader :root

    # Initialize this template with an ERB instance.
    def initialize(erb)
      @erb = erb
    end    

    # Set instance variable for this template.
    def set_variables(vars)
      for name, value in vars
        instance_variable_set("@#{name}", value)
      end
    end

    # Render this template.
    def render
      @erb.result(binding)
    end

    # Render a hash as attributes for a HTML tag. 
    def attributes(attributes)
      attributes.map { |k, v| %Q{#{k}="#{v}"} }.join(' ')
    end

    # Render a HTML tag with given name. 
    # The last argument specifies the attributes of the tag.
    # The second argument may be the content of the tag.
    def tag(name, *args)
      text, attributes = args.first.is_a?(Hash) ? [nil, args.first] : args
      "<#{name} #{attributes(attributes)}>#{text}</#{name}>"
    end

    # Render stylesheet link tags with fixed url.
    def stylesheet_link_tag(*names)
      names.map { |name|
        mtime = File.mtime("public/stylesheets/#{name}.css").to_i
        path = "#{root}stylesheets/#{name}.css?#{mtime}"
        tag :link, :href => path, :rel => 'stylesheet', :media => 'screen'
      }.join("\n")
    end

    # Render javascript tags with fixed url.
    def javascript_tag(*names)
      names.map { |name|
        mtime = File.mtime("public/javascripts/#{name}.js").to_i
        path = "#{root}javascripts/#{name}.js?#{mtime}"
        tag :script, :src => path, :type => 'text/javascript'
      }.join("\n")
    end

    # Render an image tag with fixed url.
    def image_tag(src, options = {})
      tag :img, options.merge(:src => root + 'images/' + src)
    end

    # Render a link with fixed url.
    def link_to(text, path, options = {})
      tag :a, text, options.merge(:href => root + path + '.html')
    end

    # Render a link for the navigation bar. If the text of the link
    # matches the @header variable, the css class will be set to acitve.
    def navi_link(text, path)
      link_to text, path, :class => (text == @header) ? 'active' : nil
    end

    # Render a link to a post with fixed url.
    def post_link(post)
      link_to post.title, post.path
    end

    # Render a link to an archive page.
    def month_link(year, month)
      link_to "#{Date::MONTHNAMES[month]} #{year}", "#{year}/#{month}/index"
    end

    # Render a date or time in a nice human readable format.
    def date(time)
      "%s %d, %d" % [Date::MONTHNAMES[time.month], time.day, time.year]
    end

    # Render a date or time in rfc822 format. This will be used for rss rendering.
    def rfc822(time)
      time.strftime("%a, %d %b %Y %H:%M:%S %z")
    end

    def url_encode(s)
      Shinmun.url_encode(s)
    end

  end


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

    attr_reader :root, :meta, :posts, :pages

    # Read all posts from disk. Assign guid for posts with missing guid.
    def initialize(root)
      @root = File.expand_path(root)

      Dir.chdir(@root + '/posts') do
        @meta = YAML.load(File.read('blog.yml'))

        @posts = []
        @pages = []

        for path in Dir['**/*.md']
          post = Post.new(self, path.chomp('.md'), File.read(path))
          if post.date
            if post.guid.nil?
              post.generate_guid
              File.open(post.path + '.md', 'w') do |io|
                post.write(io)
              end
            end
            @posts << post
          else
            @pages << post
          end
        end

        @posts = @posts.sort_by { |post| post.date }.reverse
      end

      @templates = {}
    end
    
    def categories
      meta['categories']
    end

    # Return template variables as hash.
    def variables
      meta.merge(:posts => posts, 
                 :months => months,
                 :categories => categories)
    end

    # Read and cache template file.
    def template(name)
      @templates[name] ||= ERB.new(File.read("#{root}/templates/#{name}"))
    end

    # Render template with given variables.
    def render_template(name, vars)
      template = Template.new(template(name))
      template.set_variables(vars)
      template.render
    end

    # Render template and insert into layout with given variables.
    def render(name, vars)
      vars = variables.merge(vars)
      content = render_template(name, vars)
      if name =~ /\.rxml$/
        content
      else
        render_template("layout.rhtml", vars.merge(:content => content))
      end
    end

    # Write a file to output directory.
    def write_file(path, data)
      FileUtils.mkdir_p(root + '/public/' + File.dirname(path))
      open(root + '/public/' + path, 'wb') do |file|
        file << data
      end    
    end

    # Render a template and write to file.
    def render_file(path, name, vars)
      puts path
      write_file(path, render(name, vars))
    end

    # Return all posts for a given month.
    def posts_for_month(year, month)
      posts.select { |p| p.year == year and p.month == month }
    end

    # Return all posts for given tag.
    def posts_for_tag(tag)
      tag = tag.downcase
      posts.select { |p| p.tags.to_s.match(tag) }
    end

    # Return all posts in given category.
    def posts_for_category(category)
      posts.select { |p| p.category == category }
    end

    # Return all months as tuples of [year, month].
    def months
      posts.map { |p| [p.year, p.month] }.uniq.sort
    end

    # Write all posts.
    def write_posts
      for post in posts
        render_file("#{post.path}.html", 
                    "post.rhtml", 
                    post.variables)
      end
    end

    # Write all pages.
    def write_pages
      for page in pages
        render_file("#{page.path}.html", 
                    "page.rhtml", 
                    page.variables)
      end
    end

    # Write archive summaries.
    def write_archives
      for year, month in months
        path = "#{year}/#{month}"
        month_name = Date::MONTHNAMES[month]
        posts = posts_for_month(year, month)

        render_file("#{path}/index.html", 
                    "posts.rhtml", 
                    :header => "#{month_name} #{year}",
                    :year => year, 
                    :month => month_name, 
                    :posts => posts,
                    :root => '../../')
      end
    end

    # Write category summaries.
    def write_categories
      for category in categories
        posts = posts_for_category(category)
        render_file("categories/#{category.downcase}.html", 
                    "posts.rhtml", 
                    :header => category,
                    :category => category, 
                    :posts => posts,
                    :root => '../')
      end
    end

    # Write index page.
    def write_index
      render_file("index.html", 
                  "posts.rhtml",
                  :header => 'Home',
                  :posts => posts[0, 10],
                  :root => '')    
    end

    # Write rss feeds for index page and categories.
    def write_feeds
      render_file("index.rss",
                  "feed.rxml",
                  :posts => posts[0, 10],
                  :root => '')
      
      for category in categories
        posts = posts_for_category(category)
        render_file("categories/#{category.downcase}.rss", 
                    "feed.rxml", 
                    :category => category, 
                    :posts => posts,
                    :root => '../')      
      end
    end

    def write_all
      write_posts
      write_pages
      write_archives
      write_categories
      write_index
      write_feeds      
    end

  end

end
