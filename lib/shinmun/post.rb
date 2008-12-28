module Shinmun
  
  # This class represents a post or page.
  # Each post has a header, encoded as YAML and a body.
  #
  # Example:
  #     --- 
  #     category: Ruby
  #     date: 2008-09-05
  #     title: BlueCloth, a Markdown library
  #     ---
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

    attr_accessor :name, :type, :src, :head, :body, :summary, :body_html, :tag_list
    head_accessor :title, :author, :date, :category, :tags

    # Initialize empty post and set specified attributes.
    def initialize(attributes={})
      @head = {}
      @body = ''
      
      attributes.each do |k, v|
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
    # yaml document if present.
    def parse(src)
      if src =~ /\A(---.*?)---(.*)/m
        @head = YAML.load($1)
        @body = $2
      else
        @body = src
      end

      @body_html = transform(@body)
      @summary = body_html.split("\n\n")[0]
      @tag_list = tags.to_s.split(",").map { |s| s.strip }

      self
    end

    # The header as yaml string.
    def dump_head
      head.empty? ? '' : head.to_yaml + "---\n"
    end

    # Convert to string representation
    def dump
      dump_head + body
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
