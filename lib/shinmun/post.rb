module Shinmun
  
  # This class represents a post or page.
  # Each post has a header, encoded as YAML and a body.
  #
  # Example:
  #     --- 
  #     category: Ruby
  #     date: 2008-09-05
  #     title: Kramdown, a Markdown library
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

    # Returns true if the post is a draft (not ready for publication)
    def draft?
      head['draft'] == true
    end

    # Estimated reading time in minutes (assumes ~200 words per minute)
    def reading_time
      @reading_time ||= begin
        # Strip markdown/HTML and count words
        plain_text = body.gsub(/```[\s\S]*?```/, ' ')  # Remove code blocks
                        .gsub(/`[^`]+`/, ' ')          # Remove inline code
                        .gsub(/\[([^\]]+)\]\([^)]+\)/, '\1')  # Extract link text
                        .gsub(/[#*_~`]/, '')           # Remove markdown formatting
                        .gsub(/<[^>]+>/, '')           # Remove HTML tags
        word_count = plain_text.split(/\s+/).reject(&:empty?).length
        [(word_count / 200.0).ceil, 1].max
      end
    end

    # Returns the word count of the post body
    def word_count
      @word_count ||= begin
        plain_text = body.gsub(/```[\s\S]*?```/, ' ')
                        .gsub(/`[^`]+`/, ' ')
                        .gsub(/\[([^\]]+)\]\([^)]+\)/, '\1')
                        .gsub(/[#*_~`]/, '')
                        .gsub(/<[^>]+>/, '')
        plain_text.split(/\s+/).reject(&:empty?).length
      end
    end

    # Generate table of contents from headings in the body
    # Returns array of hashes with :level, :text, :id
    def table_of_contents
      @table_of_contents ||= begin
        toc = []
        # Match markdown headings (## Heading)
        body.scan(/^(\#{2,6})\s+(.+)$/) do |level, text|
          clean_text = text.strip.gsub(/[#*_~`\[\]]/, '')
          id = clean_text.downcase.gsub(/\s+/, '-').gsub(/[^a-z0-9-]/, '')
          toc << { level: level.length, text: clean_text, id: id }
        end
        toc
      end
    end

    # Returns HTML for table of contents
    def toc_html
      return '' if table_of_contents.empty?
      
      items = table_of_contents.map do |entry|
        indent = '  ' * (entry[:level] - 2)
        %{#{indent}<li><a href="##{entry[:id]}">#{entry[:text]}</a></li>}
      end.join("\n")
      
      %{<nav class="table-of-contents">\n<ul>\n#{items}\n</ul>\n</nav>}
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
      return false unless file
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
        @head = YAML.safe_load($1, permitted_classes: [Date, Time, DateTime])
        @body = $2
      else
        @body = src
      end
      
      @body_html = nil
      @tag_list = nil
      @summary = nil
      @reading_time = nil
      @word_count = nil
      @table_of_contents = nil
    end

    # Convert to string representation
    def dump
      head.to_yaml + "---" + body
    end

    # Transform the body of this post. Defaults to Markdown.
    def transform(src, options={})
      case type
      when 'html'
        RubyPants.new(src).to_html
      when 'tt'
        RubyPants.new(RedCloth.new(src).to_html).to_html
      else
        # Pre-process source with Rouge highlighting if needed
        processed_src = Shinmun::KramdownRouge.process(src, options)
        # Process TypeScript embeds (pass base_path for file references)
        # For posts (posts/YYYY/MM/post.md), go up 3 levels to project root
        # For pages (pages/page.md), go up 1 level to project root
        if file
          levels_up = date ? '../../..' : '..'
          base_path = File.expand_path(levels_up, File.dirname(file))
        else
          base_path = Dir.pwd
        end
        ts_options = { base_path: base_path }
        processed_src = Shinmun::TypeScriptEmbed.process(processed_src, ts_options)
        html = Kramdown::Document.new(processed_src, input: 'GFM', syntax_highlighter: :rouge).to_html
        RubyPants.new(html).to_html
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
