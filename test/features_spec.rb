$:.unshift "#{File.dirname __FILE__}/../lib"

require 'shinmun'

RSpec.describe 'Blog Features' do
  describe Shinmun::Post do
    describe '#reading_time' do
      it 'calculates reading time for short content' do
        post = Shinmun::Post.new(title: 'Test', body: 'This is a short post.')
        expect(post.reading_time).to eq(1)
      end

      it 'calculates reading time for longer content' do
        # ~400 words should be 2 minutes at 200 wpm
        words = (['word'] * 400).join(' ')
        post = Shinmun::Post.new(title: 'Test', body: words)
        expect(post.reading_time).to eq(2)
      end

      it 'strips code blocks from word count' do
        body = "Some text\n```ruby\ndef foo; end\n```\nMore text"
        post = Shinmun::Post.new(title: 'Test', body: body)
        expect(post.reading_time).to eq(1)
      end

      it 'strips markdown formatting' do
        body = "**bold** _italic_ `code` [link](url)"
        post = Shinmun::Post.new(title: 'Test', body: body)
        expect(post.reading_time).to eq(1)
      end
    end

    describe '#word_count' do
      it 'counts words accurately' do
        post = Shinmun::Post.new(title: 'Test', body: 'one two three four five')
        expect(post.word_count).to eq(5)
      end

      it 'ignores markdown formatting' do
        post = Shinmun::Post.new(title: 'Test', body: '**bold** text')
        expect(post.word_count).to eq(2)
      end
    end

    describe '#draft?' do
      it 'returns false by default' do
        post = Shinmun::Post.new(title: 'Test')
        expect(post.draft?).to be false
      end

      it 'returns true when draft is set' do
        post = Shinmun::Post.new(title: 'Test')
        post.head['draft'] = true
        expect(post.draft?).to be true
      end

      it 'returns false when draft is explicitly false' do
        post = Shinmun::Post.new(title: 'Test')
        post.head['draft'] = false
        expect(post.draft?).to be false
      end
    end

    describe '#table_of_contents' do
      it 'extracts headings from markdown' do
        body = "## Introduction\n\nSome text\n\n### Details\n\nMore text\n\n## Conclusion"
        post = Shinmun::Post.new(title: 'Test', body: body)
        toc = post.table_of_contents

        expect(toc.length).to eq(3)
        expect(toc[0][:text]).to eq('Introduction')
        expect(toc[0][:level]).to eq(2)
        expect(toc[1][:text]).to eq('Details')
        expect(toc[1][:level]).to eq(3)
        expect(toc[2][:text]).to eq('Conclusion')
        expect(toc[2][:level]).to eq(2)
      end

      it 'generates slugified ids' do
        body = "## Hello World\n\n### Test Post Title"
        post = Shinmun::Post.new(title: 'Test', body: body)
        toc = post.table_of_contents

        expect(toc[0][:id]).to eq('hello-world')
        expect(toc[1][:id]).to eq('test-post-title')
      end

      it 'returns empty array when no headings' do
        post = Shinmun::Post.new(title: 'Test', body: 'Just some text without headings')
        expect(post.table_of_contents).to eq([])
      end
    end

    describe '#toc_html' do
      it 'generates HTML for table of contents' do
        body = "## First\n\n## Second"
        post = Shinmun::Post.new(title: 'Test', body: body)
        html = post.toc_html

        expect(html).to include('table-of-contents')
        expect(html).to include('First')
        expect(html).to include('Second')
        expect(html).to include('href="#first"')
      end

      it 'returns empty string when no headings' do
        post = Shinmun::Post.new(title: 'Test', body: 'No headings')
        expect(post.toc_html).to eq('')
      end
    end
  end

  describe Shinmun::Blog do
    DIR = '/tmp/shinmun-features-test'
    
    before do
      ENV['RACK_ENV'] = 'production'
      FileUtils.rm_rf DIR

      Shinmun::Blog.init(DIR)
      
      @blog = Shinmun::Blog.new(DIR)
      @blog.config = {
        title: 'Test Blog',
        description: 'Test Description',
        language: 'en',
        author: 'Test Author',
        categories: ['Ruby', 'Javascript'],
        site_url: 'http://example.com'
      }

      # Create test posts
      @posts = [
        Shinmun::Post.new(title: 'Ruby Post', date: Date.new(2024, 1, 1), category: 'Ruby', tags: 'ruby, programming', body: 'Ruby content'),
        Shinmun::Post.new(title: 'JS Post', date: Date.new(2024, 1, 2), category: 'Javascript', tags: 'javascript, web', body: 'JS content'),
        Shinmun::Post.new(title: 'Another Ruby', date: Date.new(2024, 1, 3), category: 'Ruby', tags: 'ruby, rails', body: 'Rails content'),
        Shinmun::Post.new(title: 'Draft Post', date: Date.new(2024, 1, 4), category: 'Ruby', tags: 'draft', body: 'Draft content')
      ]
      @posts[3].head['draft'] = true

      @blog.instance_variable_set('@posts', @posts)
      @blog.sort_posts
    end

    describe '#published_posts' do
      it 'excludes draft posts' do
        published = @blog.published_posts
        expect(published.length).to eq(3)
        expect(published.map(&:title)).not_to include('Draft Post')
      end

      it 'includes non-draft posts' do
        published = @blog.published_posts
        expect(published.map(&:title)).to include('Ruby Post')
        expect(published.map(&:title)).to include('JS Post')
      end
    end

    describe '#related_posts' do
      it 'finds posts with shared tags' do
        post = @posts[0] # Ruby Post with 'ruby, programming'
        related = @blog.related_posts(post)
        
        # Should find 'Another Ruby' which shares 'ruby' tag
        expect(related.map(&:title)).to include('Another Ruby')
      end

      it 'finds posts in same category' do
        post = @posts[0] # Ruby Post in Ruby category
        related = @blog.related_posts(post)
        
        expect(related.map(&:title)).to include('Another Ruby')
      end

      it 'excludes draft posts' do
        post = @posts[0]
        related = @blog.related_posts(post)
        
        expect(related.map(&:title)).not_to include('Draft Post')
      end

      it 'excludes the post itself' do
        post = @posts[0]
        related = @blog.related_posts(post)
        
        expect(related.map(&:title)).not_to include('Ruby Post')
      end

      it 'respects limit parameter' do
        post = @posts[0]
        related = @blog.related_posts(post, limit: 1)
        
        expect(related.length).to be <= 1
      end
    end

    describe '#recent_posts' do
      it 'returns most recent posts' do
        recent = @blog.recent_posts(limit: 2)
        expect(recent.length).to eq(2)
        # Should be sorted by date descending (newest first)
        expect(recent.first.title).to eq('Another Ruby') # Jan 3
      end

      it 'excludes drafts' do
        recent = @blog.recent_posts(limit: 10)
        expect(recent.map(&:title)).not_to include('Draft Post')
      end
    end

    describe '#tags_with_counts' do
      it 'returns tags with their post counts' do
        tags = @blog.tags_with_counts.to_h
        
        expect(tags['ruby']).to eq(2)  # In 2 non-draft posts
        expect(tags['javascript']).to eq(1)
      end

      it 'excludes tags from draft posts' do
        tags = @blog.tags_with_counts.to_h
        
        expect(tags['draft']).to be_nil
      end
    end
  end

  describe Shinmun::Helpers do
    let(:helper_class) do
      Class.new do
        include Shinmun::Helpers
        attr_accessor :blog

        def base_path
          @blog&.base_path || ''
        end
      end
    end

    let(:helper) { helper_class.new }

    describe '#reading_time_tag' do
      it 'formats reading time' do
        post = Shinmun::Post.new(title: 'Test', body: 'Short post')
        result = helper.reading_time_tag(post)
        expect(result).to eq('1 min read')
      end
    end

    describe '#paginate' do
      it 'paginates items' do
        items = (1..25).to_a
        result = helper.paginate(items, per_page: 10, current_page: 1)

        expect(result[:items]).to eq((1..10).to_a)
        expect(result[:current_page]).to eq(1)
        expect(result[:total_pages]).to eq(3)
        expect(result[:has_prev]).to be false
        expect(result[:has_next]).to be true
      end

      it 'handles middle pages' do
        items = (1..25).to_a
        result = helper.paginate(items, per_page: 10, current_page: 2)

        expect(result[:items]).to eq((11..20).to_a)
        expect(result[:has_prev]).to be true
        expect(result[:has_next]).to be true
      end

      it 'handles last page' do
        items = (1..25).to_a
        result = helper.paginate(items, per_page: 10, current_page: 3)

        expect(result[:items]).to eq((21..25).to_a)
        expect(result[:has_prev]).to be true
        expect(result[:has_next]).to be false
      end

      it 'handles invalid page numbers' do
        items = (1..10).to_a
        result = helper.paginate(items, per_page: 5, current_page: 100)

        expect(result[:current_page]).to eq(2) # Should clamp to last page
      end
    end

    describe '#html_escape_attr' do
      it 'escapes HTML entities' do
        expect(helper.html_escape_attr('<script>')).to eq('&lt;script&gt;')
        expect(helper.html_escape_attr('"test"')).to eq('&quot;test&quot;')
        expect(helper.html_escape_attr('a & b')).to eq('a &amp; b')
      end

      it 'handles nil' do
        expect(helper.html_escape_attr(nil)).to eq('')
      end
    end

    describe '#iso_date' do
      it 'formats date in ISO 8601' do
        date = Date.new(2024, 1, 15)
        expect(helper.iso_date(date)).to eq('2024-01-15')
      end
    end
  end

  describe Shinmun::Exporter do
    DIR = '/tmp/shinmun-exporter-test'
    OUTPUT_DIR = '/tmp/shinmun-export-output'
    
    before do
      FileUtils.rm_rf DIR
      FileUtils.rm_rf OUTPUT_DIR
      FileUtils.mkdir_p OUTPUT_DIR

      Shinmun::Blog.init(DIR)
      
      @blog = Shinmun::Blog.new(DIR)
      @blog.config = {
        title: 'Test Blog',
        description: 'Test Description',
        language: 'en',
        author: 'Test Author',
        categories: ['Ruby'],
        site_url: 'http://example.com',
        base_path: ''
      }

      # Create test posts
      @posts = [
        Shinmun::Post.new(title: 'Test Post', date: Date.new(2024, 1, 1), category: 'Ruby', tags: 'test', body: 'Test content')
      ]

      @blog.instance_variable_set('@posts', @posts)
      @blog.sort_posts

      @exporter = Shinmun::Exporter.new(@blog, OUTPUT_DIR)
    end

    describe '#export_sitemap' do
      it 'generates sitemap.xml' do
        @exporter.send(:export_sitemap)
        
        sitemap_path = File.join(OUTPUT_DIR, 'sitemap.xml')
        expect(File.exist?(sitemap_path)).to be true
        
        content = File.read(sitemap_path)
        expect(content).to include('<?xml version="1.0"')
        expect(content).to include('<urlset')
        expect(content).to include('<url>')
        expect(content).to include('<loc>')
      end
    end

    describe '#export_search_index' do
      it 'generates search-index.json' do
        @exporter.send(:export_search_index)
        
        index_path = File.join(OUTPUT_DIR, 'search-index.json')
        expect(File.exist?(index_path)).to be true
        
        content = JSON.parse(File.read(index_path))
        expect(content).to be_an(Array)
        expect(content.length).to eq(1)
        expect(content[0]['title']).to eq('Test Post')
      end
    end
  end
end
