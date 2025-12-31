module Kontrol

  module Helpers

    # Render a HTML tag with given name. 
    # The last argument specifies the attributes of the tag.
    # The second argument may be the content of the tag.
    def tag(name, *args)
      text, attr = args.first.is_a?(Hash) ? [nil, args.first] : args
      attributes = attr.map { |k, v| %Q{#{k}="#{v}"} }.join(' ')
      "<#{name} #{attributes}>#{text}</#{name}>"
    end

    # Render a link
    def link_to(text, path, options = {})
      tag :a, text, options.merge(:href => path)
    end

    def markdown(text, *args)
      BlueCloth.new(text, *args).to_html
    rescue => e      
      "#{text}<br/><br/><strong style='color:red'>#{e.message}</strong>"
    end

    def strip_tags(str)
      str.to_s.gsub(/<\/?[^>]*>/, "")
    end

    def urlify(string)
      string.downcase.gsub(/[ -]+/, '-').gsub(/[^-a-z0-9_]+/, '')
    end

    HTML_ESCAPE = { '&' => '&amp;', '"' => '&quot;', '>' => '&gt;', '<' => '&lt;', ' ' => '&nbsp;' }

    def h(s)
      s.to_s.gsub(/[ &"><]/) { |special| HTML_ESCAPE[special] }
    end

  end
  
end
