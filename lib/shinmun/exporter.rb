require 'stringio'

module Shinmun
  class Exporter
    attr_reader :blog, :output_dir

    def initialize(blog, output_dir = '_site')
      @blog = blog
      @output_dir = output_dir
    end

    def export
      FileUtils.rm_rf(output_dir)
      FileUtils.mkdir_p(output_dir)

      export_static_files
      export_index
      export_posts
      export_pages
      export_categories
      export_archives
      export_tags
      export_feed
      export_404

      puts "Site exported to #{output_dir}/"
    end

    private

    def export_static_files
      # Copy all static files from public directory
      public_dir = File.join(blog.path, 'public')
      if File.directory?(public_dir)
        FileUtils.cp_r(Dir.glob("#{public_dir}/*"), output_dir)
      end
    end

    def export_index
      write_file('index.html', render_with_mock_request('/'))
    end

    def export_feed
      write_file('index.rss', render_with_mock_request('/index.rss'))
    end

    def export_posts
      blog.posts.each do |post|
        path = "#{post.year}/#{post.month}/#{post.name}"
        dir = File.dirname("#{output_dir}/#{path}")
        FileUtils.mkdir_p(dir)
        write_file("#{path}.html", render_with_mock_request("/#{path}"))
      end
    end

    def export_pages
      blog.pages.each do |name, page|
        write_file("#{name}.html", render_with_mock_request("/#{name}"))
      end
    end

    def export_categories
      FileUtils.mkdir_p("#{output_dir}/categories")
      blog.categories.each do |category|
        slug = blog.send(:urlify, category)
        write_file("categories/#{slug}.html", render_with_mock_request("/categories/#{slug}"))
      end
    end

    def export_archives
      blog.archives.each do |year, month|
        dir = "#{output_dir}/#{year}"
        FileUtils.mkdir_p(dir)
        write_file("#{year}/#{month}.html", render_with_mock_request("/#{year}/#{month}"))
      end
    end

    def export_tags
      FileUtils.mkdir_p("#{output_dir}/tags")
      blog.posts_by_tag.keys.each do |tag|
        write_file("tags/#{tag}.html", render_with_mock_request("/tags/#{tag}"))
      end
    end

    def export_404
      write_file("404.html", render_with_mock_request("/not-found-page-xyz"))
    end

    def write_file(path, content)
      full_path = File.join(output_dir, path)
      File.write(full_path, content)
      puts "  Generated: #{path}"
    end

    def render_with_mock_request(path)
      # Create a mock Rack environment
      env = {
        'REQUEST_METHOD' => 'GET',
        'SCRIPT_NAME' => '',
        'PATH_INFO' => path,
        'QUERY_STRING' => '',
        'SERVER_NAME' => 'localhost',
        'SERVER_PORT' => '80',
        'HTTP_HOST' => 'localhost',
        'rack.version' => [1, 0],
        'rack.url_scheme' => 'http',
        'rack.input' => StringIO.new(''),
        'rack.errors' => $stderr,
        'rack.multithread' => false,
        'rack.multiprocess' => false,
        'rack.run_once' => true
      }

      status, headers, body = blog.call(env)
      
      # Collect response body
      result = []
      if body.respond_to?(:each)
        body.each { |chunk| result << chunk }
      else
        result << body.to_s
      end
      result.join
    end
  end
end
