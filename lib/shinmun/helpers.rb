module Shinmun

  module Helpers

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
        mtime = File.mtime("assets/#{blog.stylesheets_path}/#{name}.css").to_i
        path = "/#{blog.stylesheets_path}/#{name}.css?#{mtime}"
        tag :link, :href => path, :rel => 'stylesheet', :media => 'screen'
      }.join("\n")
    end

    # Render javascript tag
    def javascript_tag(*names)
      names.map { |name|
        mtime = File.mtime("assets/#{blog.javascripts_path}/#{name}.js").to_i
        path = "/#{blog.javascripts_path}/#{name}.js?#{mtime}"
        tag :script, :src => path, :type => 'text/javascript'
      }.join("\n")
    end

    # Render an image tag
    def image_tag(file, options = {})
      mtime = File.mtime("assets/#{blog.images_path}/#{file}").to_i
      path = "/#{blog.images_path}/#{file}?#{mtime}"
      tag :img, options.merge(:src => path)
    end

    # Render a link
    def link_to(text, path, options = {})
      tag :a, text, options.merge(:href => path)
    end

    # Render a link to a post
    def post_link(post)
      link_to post.title, "#{blog.base_path}/#{post.path}.html"
    end

    # Render a link to an archive page.
    def archive_link(year, month)
      link_to "#{Date::MONTHNAMES[month]} #{year}", "#{blog.base_path}/#{year}/#{month}/index.html"
    end

    # Render a date or time in a nice human readable format.
    def date(time)
      "%s %d, %d" % [Date::MONTHNAMES[time.month], time.day, time.year]
    end

    # Render a date or time in rfc822 format. This will be used for rss rendering.
    def rfc822(time)
      time.strftime("%a, %d %b %Y %H:%M:%S %z")
    end

    def markdown(text, *args)
      BlueCloth.new(text, *args).to_html
    rescue => e      
      "#{text}<br/><br/><strong style='color:red'>#{e.message}</strong>"
    end

    def strip_tags(str)
      str.gsub(/<\/?[^>]*>/, "")
    end

    def urlify(string)
      string.downcase.gsub(/[ -]+/, '-').gsub(/[^-a-z0-9_]+/, '')
    end

    # taken form ActionView::Helpers
    def distance_of_time_in_words(from_time, to_time = 0, include_seconds = false)
      from_time = from_time.to_time if from_time.respond_to?(:to_time)
      to_time = to_time.to_time if to_time.respond_to?(:to_time)
      distance_in_minutes = (((to_time - from_time).abs)/60).round
      distance_in_seconds = ((to_time - from_time).abs).round

      case distance_in_minutes
      when 0..1
        return (distance_in_minutes == 0) ? 'less than a minute' : '1 minute' unless include_seconds
        case distance_in_seconds
        when 0..4   then 'less than 5 seconds'
        when 5..9   then 'less than 10 seconds'
        when 10..19 then 'less than 20 seconds'
        when 20..39 then 'half a minute'
        when 40..59 then 'less than a minute'
        else             '1 minute'
        end

      when 2..44           then "#{distance_in_minutes} minutes"
      when 45..89          then 'about 1 hour'
      when 90..1439        then "about #{(distance_in_minutes.to_f / 60.0).round} hours"
      when 1440..2879      then '1 day'
      when 2880..43199     then "#{(distance_in_minutes / 1440).round} days"
      when 43200..86399    then 'about 1 month'
      when 86400..525599   then "#{(distance_in_minutes / 43200).round} months"
      when 525600..1051199 then 'about 1 year'
      else                      "over #{(distance_in_minutes / 525600).round} years"
      end
    end
  end
  
end
