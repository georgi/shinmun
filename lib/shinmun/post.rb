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

    attr_writer :name
    attr_accessor :src, :type, :head, :body, :file, :mtime

    # Initialize empty post and set specified attributes.
    def initialize(attributes={})
      @head = {}
      @body = ''
      @type = 'md'
      
      attributes.each do |k, v|
        send "#{k}=", v
      end
      
      load if file
    end

    def name
      @name ||= title.to_s.downcase.gsub(/[ -]+/, '-').gsub(/[^-a-z0-9_]+/, '')
    end

    def method_missing(id, *args)
      key = id.to_s
      if @head.has_key?(key)
        @head[key]
      else
        raise NoMethodError, "undefined method `#{id}' for #{self}", caller(1)
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

    def tag_list
      @tag_list ||= tags.to_s.split(",").map { |s| s.strip }
    end

    def body_html
      @body_html ||= transform(@body)
    end

    def summary
      @summary ||= body_html.split("\n\n")[0]
    end

    def path
      folder = date ? "posts/#{year}/#{month}" : 'pages'
      "#{folder}/#{name}.#{type}"
    end

    def load
      self.type = File.extname(file)[1..-1]
      self.name = File.basename(file).chomp(".#{type}")
      self.mtime = File.mtime(file)
      
      parse(File.read(file))
    end

    def changed?
      File.mtime(file) != mtime
    end

    def save
      FileUtils.mkpath(File.dirname(path))
      File.open(path, 'w') do |io|
        io << dump
      end
    end

    # Split up the source into header and body. Load the header as
    # yaml document.
    def parse(src)
      if src =~ /\A---(.*?)---(.*)/m
        @head = YAML.load($1)
        @body = $2
      else
        @body = src
      end
      
      @body_html = nil
      @tag_list = nil
      @summary = nil
    end

    # Convert to string representation
    def dump
      head.to_yaml + "---" + body
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
      Post === obj and file == obj.file
    end

  end

end
