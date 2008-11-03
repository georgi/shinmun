module Shinmun
  
  # This class represents an article or page.
  # A post has a header and body text.
  # Example:
  #     --- 
  #     category: Ruby
  #     date: 2008-09-05
  #     guid: 7ad04f10-5dd6-012b-b53c-001a92975b89
  #      
  #     BlueCloth, a Markdown library
  #     =============================
  #
  #     This is the summary, which is by definition the first paragraph of the
  #     article. The summary shows up in list views and rss feeds.  
  class Post

    def self.head_accessor(*names)
      names.each do |name|
        name = name.to_s
        define_method(name) { @head[name] }
        define_method("#{name}=") {|v| @head[name] = v }
      end
    end

    attr_reader :blog, :path, :type
    attr_accessor :title, :head, :body
    head_accessor :date, :category, :tags, :languages, :guid

    def initialize(blog, path)
      @blog = blog
      @type = File.extname(path)[1..-1]
      @path = path.chomp(File.extname(path))
      @head = {}
      @body = ''
    end

    def author
      @head['author'] || blog.meta['blog_author']
    end

    def year ; date.year  end
    def month; date.month end

    # Return the first paragraph
    def summary
      body_html.split("\n\n")[0]
    end

    # Split up the source text into header and body.
    # Load the header as yaml document.
    def load
      src = File.read("#{path}.#{type}")

      # Parse YAML header if present
      if src =~ /---.*?\n(.*?)\n\n(.*)/m
        @head = YAML.load($1)
        @body = $2
      else
        @body = src
      end

      @title = head['title'] or parse_title
      self
    end

    # Parse title from different formats
    def parse_title
      lines = body.split("\n")

      case type
      when 'md'
        @title = lines.shift.sub(/(^#+|#+$)/,'').strip
        lines.shift if lines.first.match(/^(=|-)+$/)

      when 'html'
        @title = lines.shift.sub(/(<h1>|\<\/h1>)/,'').strip

      when 'tt'
        @title = lines.shift.sub(/(^h1.)/,'').strip
      end

      @body = lines.join("\n")
    end

    def filename
      "posts/#{path}.#{type}"
    end

    def save
      FileUtils.mkdir_p(File.dirname(filename))
      File.open(filename, "w") { |io| io << dump }
    end

    def dump
      head = self.head.dup
      body = self.body.dup

      if type == 'md'        
        body = title + "\n" + ("=" * title.size) + "\n\n" + body
      end

      head.each do |k, v|        
        head.delete(k) if v.nil? || v.empty?
      end
      
      if head.empty?
        body
      else
        head.to_yaml + "\n\n" + body
      end
    end

    def variables
      head.merge(:blog => blog,
                 :author => author,
                 :path => path,
                 :title => title,
                 :body => body_html)
    end

    # Generates the body from source text.
    def body_html
      @body_html ||= transform(body, type)
    end

    def transform(src, type)
      case type
      when 'html'
        RubyPants.new(src).to_html
      when 'rhtml'
        template = Template.new(ERB.new(src), blog)
        template.set_variables(head.merge(:blog => blog, :path => path, :title => title))
        template.render
      when 'tt'
        RubyPants.new(RedCloth.new(src).to_html).to_html
      else
        RubyPants.new(BlueCloth.new(src).to_html).to_html
      end
    end

  end

end
