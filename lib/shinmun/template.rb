
module Shinmun

  module Helpers
  end

  # This class renders an ERB template for a set of attributes, which
  # are accessible as instance variables.
  class Template
    include Helpers

    attr_reader :erb, :blog

    # Initialize this template with an ERB instance.
    def initialize(erb, blog)
      @erb = erb
      @blog = blog
    end    

    # Set instance variable for this template.
    def set_variables(vars)
      for name, value in vars
        instance_variable_set("@#{name}", value)
      end
      self
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

    # Render stylesheet link tag
    def stylesheet_link_tag(*names)
      names.map { |name|
        mtime = File.mtime("public/#{blog.stylesheets_path}/#{name}.css").to_i
        path = "/#{blog.stylesheets_path}/#{name}.css?#{mtime}"
        tag :link, :href => path, :rel => 'stylesheet', :media => 'screen'
      }.join("\n")
    end

    # Render javascript tag
    def javascript_tag(*names)
      names.map { |name|
        mtime = File.mtime("public/#{blog.javascripts_path}/#{name}.js").to_i
        path = "/#{blog.javascripts_path}/#{name}.js?#{mtime}"
        tag :script, :src => path, :type => 'text/javascript'
      }.join("\n")
    end

    # Render an image tag
    def image_tag(file, options = {})
      mtime = File.mtime("public/#{blog.images_path}/#{file}").to_i
      path = "/#{blog.images_path}/#{file}?#{mtime}"
      tag :img, options.merge(:src => path)
    end

    # Render a link
    def link_to(text, path, options = {})
      tag :a, text, options.merge(:href => "/#{path}.html")
    end

    # Render a link to a post
    def post_link(post)
      link_to post.title, "#{blog.base_path}/#{post.path}"
    end

    # Render a link to an archive page.
    def archive_link(year, month)
      link_to "#{Date::MONTHNAMES[month]} #{year}", "#{blog.base_path}/#{year}/#{month}/index"
    end

    # Render a date or time in a nice human readable format.
    def date(time)
      "%s %d, %d" % [Date::MONTHNAMES[time.month], time.day, time.year]
    end

    # Render a date or time in rfc822 format. This will be used for rss rendering.
    def rfc822(time)
      time.strftime("%a, %d %b %Y %H:%M:%S %z")
    end

    def strip_tags(html)
      Shinmun.strip_tags(html)
    end

  end

end
