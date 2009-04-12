module Shinmun

  module Helpers

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
    
    # Render a link for the navigation bar. If the text of the link
    # matches the @header variable, the css class will be set to acitve.
    def navi_link(text, path)
      link_to text, path, :class => (request.path_info == path) ? 'active' : nil
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
