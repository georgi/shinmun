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

    %w[title author date category tags].each do |name|
      define_method(name) { head[name] }
      define_method("#{name}=") {|v| head[name] = v }
    end

    attr_accessor :dirname, :name, :type, :src, :head, :body, :summary, :body_html, :tag_list

    # Initialize empty post and set specified attributes.
    def initialize(attributes={})
      @head = {}
      @body = ''
      
      attributes.each do |k, v|
        send "#{k}=", v
      end

      @type ||= 'md'
      
      parse(src) if src

      raise "post without a title" if title.nil?
      
      @name ||= title.downcase.gsub(/[ -]+/, '-').gsub(/[^-a-z0-9_]+/, '')
      @dirname = date ? "posts/#{year}/#{month}" : 'pages'      
    end

    def method_missing(id, *args)
      key = id.to_s
      if @head.has_key?(key)
        @head[key]
      else
        raise NoMethodError, "undefined method `#{id}' for #{self}", caller(1)
      end
    end

    def date=(date)
      @head['date'] = String === date ? Date.parse(date) : date
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
      dirname.to_s.empty? ? filename : "#{dirname}/#{filename}"
    end

    def path=(path)
      list = path.split('/')
      self.dirname = list[0..-2].join('/')
      self.filename = list[-1]
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
      @dirname = date ? "posts/#{year}/#{month}" : 'pages'

      self
    end

    # Convert to string representation
    def dump
      (head.empty? ? '' : head.to_yaml + "---") + body
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
      self == obj
    end

    def ==(obj)
      if Post === obj
        if date
          year == obj.year and month == obj.month and name == obj.name
        else
          name == obj.name
        end
      end
    end

  end

end
