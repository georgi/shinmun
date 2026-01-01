module Shinmun

  module Helpers

    Kontrol::Template.send(:include, self)

    def post_path(post)
      "#{base_path}/#{post.year}/#{post.month}/#{post.name}"
    end    

    def archive_path(year, month)
      "#{base_path}/#{year}/#{month}"
    end

    # Render a link to a post
    def post_link(post)
      link_to post.title, post_path(post)
    end

    # Render a link to an archive page.
    def archive_link(year, month)
      link_to "#{Date::MONTHNAMES[month]} #{year}", archive_path(year, month)
    end

    # Render a date or time in a nice human readable format.
    def human_date(time)
      "%s %d, %d" % [Date::MONTHNAMES[time.month], time.day, time.year]
    end

    # Render a date or time in rfc822 format.
    def rfc822(time)
      time.strftime("%a, %d %b %Y %H:%M:%S %z")
    end
    
    # Render a link for the navigation bar.
    def navi_link(text, path)
      active = request.path_info == path

      if path.match(/categories\/(.*)/) 
        category = $1
        if request.path.match(/(\d+)\/(\d+)\/(.*)/)
          post = posts_by_date[$1.to_i][$2.to_i][$3]
          active ||= category == urlify(post.category) if post
        end
      end
      
      link_to text, path, :class => active ? 'active' : nil
    end

    def html_escape(s)
      s.to_s.gsub(/>/, '&gt;').gsub(/</n, '&lt;')
    end

    def diff_line_class(line)
      case line[0, 1]
      when '+' then 'added'
      when '-' then 'deleted'
      end
    end

    # Render a script tag that sets window variables from config
    # Usage in templates: <%= variables_script_tag %>
    def variables_script_tag
      vars = @blog.variables
      return '' if vars.nil? || vars.empty?

      require 'json'

      js_vars = vars.map do |key, value|
        # Validate key contains only safe characters (alphanumeric and underscore)
        safe_key = key.to_s
        unless safe_key.match?(/\A[A-Za-z_][A-Za-z0-9_]*\z/)
          next nil # Skip invalid keys
        end

        # Use JSON encoding for safe value escaping
        encoded_value = value.to_s.to_json
        "window.#{safe_key} = #{encoded_value};"
      end.compact.join("\n  ")

      return '' if js_vars.empty?
      "<script>\n  #{js_vars}\n</script>"
    end

  end
end
