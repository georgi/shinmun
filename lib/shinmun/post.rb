module Shinmun
  
  # This class represents a post or page.
  # Each post has a header, encoded as YAML and a body.
  #
  # Example:
  #     --- 
  #     category: Ruby
  #     date: 2008-09-05
  #      
  #     BlueCloth, a Markdown library
  #     =============================
  #
  #     This is the summary, which is by definition the first paragraph of the
  #     article. The summary shows up in list views and rss feeds.  
  #
  class Post

    # Define accessor methods for head variable.
    def self.head_accessor(*names)
      names.each do |name|
        name = name.to_s
        define_method(name) { @head[name] }
        define_method("#{name}=") {|v| @head[name] = v }
      end
    end

    attr_accessor :prefix, :path, :type, :title, :head, :body, :summary, :body_html
    head_accessor :author, :date, :category, :tags, :languages, :header

    # Initialize empty post and set specified attributes.
    def initialize(attributes={})
      @head = {}
      @body = ''
      
      for k, v in attributes
        send "#{k}=", v
      end
    end

    # Shortcut for year of date
    def year
      date.year
    end

    # Shortcut for month of date
    def month
      date.month
    end    

    def filename
      "#{prefix}/#{path}.#{type}"
    end

    # Strips off extension and prefix.
    def filename=(file)
      if match = file.match(/^(.*?)\/(.*)\.(.*)/)
        @prefix = match[1]
        @path = match[2]
        @type = match[3]
      else
        raise "incorrect filename: #{file}"
      end
    end

    # Split up the source into header and body. Load the header as
    # yaml document. Render body and parse the summary from rendered html.
    def parse(src)
      # Parse YAML header if present
      if src =~ /---.*?\n(.*?)\n\n(.*)/m
        @head = YAML.load($1)
        @body = $2
      else
        @body = src
      end

      @title = head['title'] or parse_title
      @body_html = transform(body, type)
      @summary = body_html.split("\n\n")[0]

      self
    end

    # Parse title from different formats
    def parse_title
      lines = body.split("\n")

      return if lines.empty?

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

    # Convert to yaml for caching.
    def to_yaml
      head.merge('author' => author,
                 'path' => path,
                 'type' => type,
                 'title' => title,
                 'summary' => summary,
                 'body_html' => body_html).to_yaml
    end

    # Convert to string representation, used to create new posts.
    def dump
      head = self.head.dup
      body = self.body.dup

      if type == 'md'        
        body = title + "\n" + ("=" * title.size) + "\n\n" + body
      end

      head.each do |k, v|        
        head.delete(k) if v.nil? || (v.respond_to?(:empty?) && v.empty?)
      end
      
      if head.empty?
        body
      else
        head.to_yaml + "\n" + body
      end
    end

    def load
      parse(File.read(filename))
    end

    def save
      FileUtils.mkdir_p(File.dirname(filename))
      File.open(filename, "w") { |io| io << dump }
      self
    end

    # Variables used for templates.
    def variables
      head.merge(:author => author,
                 :path => path,
                 :title => title,
                 :body => body_html)
    end

    # Transform the body of this post according to given type.
    # Defaults to Markdown.
    def transform(src, type)
      case type
      when 'html'
        RubyPants.new(src).to_html
      when 'tt'
        RubyPants.new(RedCloth.new(src).to_html).to_html
      else
        RubyPants.new(BlueCloth.new(src).to_html).to_html
      end
    end

  end

end
