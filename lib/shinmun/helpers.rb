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

    # Render a date in ISO 8601 format (for SEO meta tags)
    def iso_date(time)
      time.strftime("%Y-%m-%d")
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

    # Render reading time for a post
    # Usage: <%= reading_time_tag @post %>
    def reading_time_tag(post)
      minutes = post.reading_time
      "#{minutes} min read"
    end

    # Generate SEO meta tags for Open Graph and Twitter Cards
    # Usage in templates: <%= seo_meta_tags(post: @post) %> or <%= seo_meta_tags %>
    def seo_meta_tags(options = {})
      post = options[:post]
      page = options[:page]
      
      tags = []
      
      # Basic meta
      if post
        title = post.title
        description = post.head['description'] || post.summary&.gsub(/<[^>]+>/, '')&.strip&.slice(0, 160)
        url = post_url(post)
        date = post.date
        og_type = 'article'
      elsif page
        title = page.title
        description = page.head['description'] || page.summary&.gsub(/<[^>]+>/, '')&.strip&.slice(0, 160)
        url = page_url(page)
        date = nil
        og_type = 'website'
      else
        title = @blog.title
        description = @blog.description
        url = @blog.url
        date = nil
        og_type = 'website'
      end
      
      # Escape HTML entities for attribute values
      title_escaped = html_escape_attr(title)
      description_escaped = html_escape_attr(description) if description
      
      # Open Graph tags
      tags << %(<meta property="og:title" content="#{title_escaped}" />)
      tags << %(<meta property="og:type" content="#{og_type}" />)
      tags << %(<meta property="og:url" content="#{url}" />) if url
      tags << %(<meta property="og:description" content="#{description_escaped}" />) if description_escaped
      tags << %(<meta property="og:site_name" content="#{html_escape_attr(@blog.title)}" />)
      
      if og_type == 'article' && date
        tags << %(<meta property="article:published_time" content="#{iso_date(date)}" />)
        tags << %(<meta property="article:author" content="#{html_escape_attr(@blog.author)}" />) if @blog.author
      end
      
      # Twitter Card tags
      tags << %(<meta name="twitter:card" content="summary" />)
      tags << %(<meta name="twitter:title" content="#{title_escaped}" />)
      tags << %(<meta name="twitter:description" content="#{description_escaped}" />) if description_escaped
      
      # Canonical URL
      tags << %(<link rel="canonical" href="#{url}" />) if url
      
      # Description meta tag
      tags << %(<meta name="description" content="#{description_escaped}" />) if description_escaped
      
      tags.join("\n    ")
    end

    # Helper to get full URL for a post
    def post_url(post)
      "#{@blog.url}#{post_path(post)}"
    end

    # Helper to get full URL for a page
    def page_url(page)
      "#{@blog.url}#{base_path}/#{page.name}"
    end

    # Escape string for use in HTML attributes
    def html_escape_attr(s)
      return '' if s.nil?
      s.to_s.gsub('&', '&amp;').gsub('"', '&quot;').gsub('<', '&lt;').gsub('>', '&gt;')
    end

    # Render related posts for a given post
    # Usage: <%= related_posts_html @post, limit: 3 %>
    def related_posts_html(post, limit: 5)
      related = @blog.related_posts(post, limit: limit)
      return '' if related.empty?
      
      items = related.map do |p|
        %(<li><a href="#{post_path(p)}">#{html_escape(p.title)}</a></li>)
      end.join("\n  ")
      
      %(<nav class="related-posts">\n<h4>Related Posts</h4>\n<ul>\n  #{items}\n</ul>\n</nav>)
    end

    # Pagination helper
    # Usage: paginate(@posts, per_page: 10, current_page: params[:page])
    # Returns: { items: [...], current_page: 1, total_pages: 5, has_prev: false, has_next: true }
    def paginate(items, per_page: 10, current_page: 1)
      current_page = [current_page.to_i, 1].max
      total_items = items.length
      total_pages = [(total_items / per_page.to_f).ceil, 1].max
      current_page = [current_page, total_pages].min
      
      start_index = (current_page - 1) * per_page
      paginated_items = items[start_index, per_page] || []
      
      {
        items: paginated_items,
        current_page: current_page,
        total_pages: total_pages,
        total_items: total_items,
        per_page: per_page,
        has_prev: current_page > 1,
        has_next: current_page < total_pages,
        prev_page: current_page > 1 ? current_page - 1 : nil,
        next_page: current_page < total_pages ? current_page + 1 : nil
      }
    end

    # Render pagination HTML
    # Usage: <%= pagination_html(pagination, base_url: '/') %>
    def pagination_html(pagination, base_url: '/')
      return '' if pagination[:total_pages] <= 1
      
      links = []
      
      if pagination[:has_prev]
        prev_url = pagination[:prev_page] == 1 ? base_url : "#{base_url}?page=#{pagination[:prev_page]}"
        links << %(<a href="#{prev_url}" class="pagination-prev">&laquo; Previous</a>)
      end
      
      links << %(<span class="pagination-info">Page #{pagination[:current_page]} of #{pagination[:total_pages]}</span>)
      
      if pagination[:has_next]
        links << %(<a href="#{base_url}?page=#{pagination[:next_page]}" class="pagination-next">Next &raquo;</a>)
      end
      
      %(<nav class="pagination">\n  #{links.join("\n  ")}\n</nav>)
    end

  end
end
