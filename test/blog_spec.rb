$:.unshift "#{File.dirname __FILE__}/../lib"

require 'shinmun'
require 'rack/test'
require 'rexml/document'
require 'rexml/xpath'
require 'pp'

RSpec.describe Shinmun::Blog do

  DIR = '/tmp/shinmun-test'

  attr_reader :blog

  before do
    ENV['RACK_ENV'] = 'production'
    
    FileUtils.rm_rf DIR

    Shinmun::Blog.init(DIR)
    
    @blog = Shinmun::Blog.new(DIR)
    
    blog.config = {
      :title => 'Title',
      :description => 'Description',
      :language => 'en',
      :author =>  'The Author',
      :categories => ['Ruby', 'Javascript']
    }
    
    @posts = [Shinmun::Post.new(:title => 'New post', :date => Date.new(2008,10,10), :category => 'Ruby', :body => 'Body1'),
              Shinmun::Post.new(:title => 'And this', :date => Date.new(2008,10,11), :category => 'Ruby', :body => 'Body2'),
              Shinmun::Post.new(:title => 'Again',    :date => Date.new(2008,11,10), :category => 'Javascript', :body => 'Body3')]

    @pages = {
      'page-1' => Shinmun::Post.new(:title => 'Page 1', :body => 'Body1'),
      'page-2' => Shinmun::Post.new(:title => 'Page 2', :body => 'Body2')
    }

    blog.instance_variable_set('@posts', @posts)
    blog.instance_variable_set('@pages', @pages)

    blog.sort_posts
  end

  def request(method, uri, options={})
    @request = Rack::MockRequest.new(blog)    
    @response = @request.request(method, uri, options)
  end

  def get(*args)
    request(:get, *args)
  end

  def post(*args)
    request(:post, *args)
  end  

  def xpath(xml, path)
    REXML::XPath.match(REXML::Document.new(xml), path)
  end

  def query(hash)
    Rack::Utils.build_query(hash)
  end
  
  def assert_listing(xml, list)
    titles = xpath(xml, "//h2/a")
    summaries = xpath(xml, "//p")

    list.each_with_index do |(title, summary), i|
      expect(titles[i].text).to eq(title)
      expect(summaries[i].text.to_s.strip).to eq(summary)
    end
  end

  it "should load templates" do
    expect(blog.load_template("index.rhtml")).to be_kind_of(Kontrol::Template)
  end

  it "should find posts for a category" do    
    expect(blog.find_category('ruby')).to eq('Ruby')
    
    expect(blog.posts_by_category['Ruby']).to include(@posts[0])
    expect(blog.posts_by_category['Ruby']).to include(@posts[1])

    expect(blog.find_category('javascript')).to eq('Javascript')
    expect(blog.posts_by_category['Javascript']).to include(@posts[2])
  end

  it "should render posts" do
    xml = get('/2008/10/new-post').body
    
    expect(xpath(xml, "//h1")[0].text).to eq('New post')
    expect(xpath(xml, "//p")[0].text).to eq('Body1')
  end

  it "should render categories" do    
    assert_listing(get('/categories/ruby').body, [['And this', 'Body2'], ['New post', 'Body1']])
  end

  it "should render index and archives" do
    expect(blog.posts_by_date[2008][10]).not_to be_empty
    expect(blog.posts_by_date[2008][11]).not_to be_empty
    
    assert_listing(get('/2008/10').body, [['And this', 'Body2'], ['New post', 'Body1']])
    assert_listing(get('/').body, [['Again', 'Body3'], ['And this', 'Body2'], ['New post', 'Body1']])
  end

  it "should render pages" do
    xml = get('/page-1').body
    expect(xpath(xml, "//h1")[0].text).to eq('Page 1')
    expect(xpath(xml, "//p")[0].text).to eq('Body1')

    xml = get('/page-2').body    
    expect(xpath(xml, "//h1")[0].text).to eq('Page 2')
    expect(xpath(xml, "//p")[0].text).to eq('Body2')
  end

  it "should render a post" do
    xml = get('/2008/10/new-post').body

    expect(xpath(xml, "//h1")[0].text).to eq('New post')
    expect(xpath(xml, "//div[@class='date']")[0].text.strip).to eq('October 10, 2008')
  end
  
end
