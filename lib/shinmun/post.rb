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

    attr_accessor :name, :type, :title, :src, :head, :body, :summary, :body_html, :tag_list
    head_accessor :author, :date, :category, :tags, :languages, :header

    # Initialize empty post and set specified attributes.
    def initialize(attributes={})
      @head = {}
      @body = ''
      
      for k, v in attributes
        send "#{k}=", v
      end

      parse src if src
    end

    def method_missing(id, *args)
      key = id.to_s
      if @head.has_key?(key)
        @head[key]
      else
        raise NoMethodError, "undefined method `#{id}' for #{self}", caller(1)
      end
    end

    def date=(d)
      @head['date'] = String === d ? Date.parse(d) : d
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
      "#{name}.#{type}"
    end

    def filename=(filename)
      self.name, self.type = filename.split('.')
    end

    def path
      if date
        "#{year}/#{month}/#{name}"
      else
        name
      end
    end

    # Split up the source into header and body. Load the header as
    # yaml document. Render body and parse the summary from rendered html.
    def parse(src)
      src = src.delete("\r")

      # Parse YAML header if present
      if src =~ /\A(---.*?)\n\n(.*)/m
        @head = YAML.load($1)
        @body = $2
      else
        @body = src
      end

      @title = head['title'] or parse_title
      @body_html = transform(body)
      @summary = body_html.split("\n\n")[0]
      @tag_list = tags.to_s.split(",").map { |s| s.strip }

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

    # Convert to string representation
    def dump
      str = head.empty? ? '' : head.to_yaml + "\n"
      unless head['title']
        str << \
        case type
        when 'md'   : "#{title}\n#{'=' * title.size}\n"
        when 'html' : "<h1>#{title}</h1>\n"
        when 'tt'   : "h1.#{title}\n"
        else raise
        end
      end
      str + body
    end

    # Transform the body of this post. Defaults to Markdown.
    def transform(src)
      case type
      when 'html'
        RubyPants.new(src).to_html
      when 'tt'
        RubyPants.new(RedCloth.new(src).to_html).to_html
      else
        RubyPants.new(BlueCloth.new(src).to_html).to_html
      end
    end

    def eql?(obj)
      path == obj.path
    end

    def ==(obj)
      path == obj.path
    end

  end

end
