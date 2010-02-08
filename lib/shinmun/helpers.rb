module Shinmun

  module Helpers

    Kontrol::Template.send(:include, self)

    def post_path(post)
      "/#{post.year}/#{post.month}/#{post.name}"
    end    

    def archive_path(year, month)
      "/#{year}/#{month}"
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
      if path.match(/categories\/(.*)/)        
        active = $1 == urlify(@category) if @category
        active = $1 == urlify(@post.category) if @post
      else
        active = request.path_info == path
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

  end
end
