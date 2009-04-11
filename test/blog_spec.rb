require 'shinmun'
require 'rack/mock'
require 'rexml/xpath'
require 'pp'

describe Shinmun::Blog do

  TEST_DIR = File.expand_path(File.dirname(__FILE__))
  TEMPLATES_DIR = File.expand_path(TEST_DIR + '/templates')
  REPO = TEST_DIR + '/repo'

  before do
    FileUtils.rm_rf REPO
    Dir.mkdir REPO
    Dir.chdir REPO
    initialize_blog
  end
  
  def file(file, data)
    FileUtils.mkpath(File.dirname(file))
    open(file, 'w') { |io| io << data }
    `git add #{file}`
  end

  def initialize_blog
    `git init`
    
    file 'config/blog.yml', {
      'title' => 'Title',
      'description' => 'Description',
      'language' => 'en',
      'author' =>  'The Author',
      'url' => 'http://www.my-blog-url.com',
      'categories' => ['Ruby', 'Javascript']
    }.to_yaml

    ENV['RACK_ENV'] = 'production'
    @blog = Shinmun::Blog.new(REPO)
    @request = Rack::MockRequest.new(@blog)

    Dir.mkdir 'templates'
    
    Dir[TEMPLATES_DIR + '/*'].each do |path|      
      unless path.include?('~')
        file 'templates/' + File.basename(path), File.read(path)
      end
    end

    `git commit -m 'spec'` 
    
    @blog.store.load

    @posts = [@blog.create_post(:title => 'New post', :date => '2008-10-10', :category => 'Ruby', :body => 'Body1'),
              @blog.create_post(:title => 'And this', :date => '2008-10-11', :category => 'Ruby', :body => 'Body2'),
              @blog.create_post(:title => 'Again',    :date => '2008-11-10', :category => 'Javascript', :body => 'Body3')]

    @pages = [@blog.create_post(:title => 'Page 1', :body => 'Body1'),
              @blog.create_post(:title => 'Page 2', :body => 'Body2')]

    @blog.store.load
  end

  def get(*args)
    @request.get(*args)
  end

  def post(*args)
    @request.post(*args)
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
      titles[i].text.should == title
      summaries[i].text.to_s.strip.should == summary
    end
  end 

  it "should find posts for a category" do    
    category = @blog.find_category('ruby')
    category[:name].should == 'Ruby'
    
    category[:posts].should include(@posts[0])
    category[:posts].should include(@posts[1])

    category = @blog.find_category('javascript')
    category[:name].should == 'Javascript'
    category[:posts].should include(@posts[2])
  end

  it "should create a post" do
    @blog.create_post(:title => 'New post', :date => '2008-10-10')
    @blog.store.load
    
    post = @blog.find_post(2008, 10, 'new-post')
    post.should_not be_nil
    post.title.should == 'New post'
    post.date.should == Date.new(2008, 10, 10)
    post.name.should == 'new-post'
  end

  it "should update a post" do
    post = @blog.create_post(:title => 'New post', :date => '2008-10-10')
    @blog.update_post(post, "---\ndate: 2008-11-11\ntitle: The title\n---")
    @blog.store.load

    post = @blog.find_post(2008, 11, 'new-post')
    post.should_not be_nil
    post.title.should == 'The title'
    post.date.should == Date.new(2008, 11, 11)
    post.name.should == 'new-post'
  end

  it "should delete a post" do
    post = @blog.create_post(:title => 'New post', :date => '2008-10-10')
    @blog.delete_post(post)        
    @blog.store.load

    @blog.find_post(2008, 10, 'new-post').should be_nil
  end

  it "should render posts" do
    xml = get('/2008/10/new-post').body

    xpath(xml, "//h1")[0].text.should == 'New post'
    xpath(xml, "//p")[0].text.should == 'Body1'
  end

  it "should render categories" do
    get('/categories/ruby.rss')['Content-Type'].should == 'application/rss+xml'

    xml = get('/categories/ruby.rss').body

    xpath(xml, '/rss/channel/title')[0].text.should == 'Ruby'
    xpath(xml, '/rss/channel/item/title')[0].text.should == 'And this'
    xpath(xml, '/rss/channel/item/pubDate')[0].text.should == "Sat, 11 Oct 2008 00:00:00 +0000"
    xpath(xml, '/rss/channel/item/link')[0].text.should == "http://www.my-blog-url.com/2008/10/and-this"
    xpath(xml, '/rss/channel/item/title')[1].text.should == 'New post'
    xpath(xml, '/rss/channel/item/pubDate')[1].text.should == "Fri, 10 Oct 2008 00:00:00 +0000"
    xpath(xml, '/rss/channel/item/link')[1].text.should == "http://www.my-blog-url.com/2008/10/new-post"
    
    assert_listing(get('/categories/ruby').body, [['And this', 'Body2'], ['New post', 'Body1']])
  end

  it "should render index and archives" do
    @blog.posts_for_month(2008, 10).should_not be_empty
    @blog.posts_for_month(2008, 11).should_not be_empty
    
    assert_listing(get('/2008/10').body, [['And this', 'Body2'], ['New post', 'Body1']])
    assert_listing(get('/').body, [['Again', 'Body3'], ['And this', 'Body2'], ['New post', 'Body1']])
  end

  it "should render pages" do
    xml = get('/page-1').body
    xpath(xml, "//h1")[0].text.should == 'Page 1'
    xpath(xml, "//p")[0].text.should == 'Body1'

    xml = get('/page-2').body    
    xpath(xml, "//h1")[0].text.should == 'Page 2'
    xpath(xml, "//p")[0].text.should == 'Body2'
  end

  it "should post a comment" do    
    post "/comments?path=posts/2008/10/new-post.md&name=Hans&text=Hallo"
    post "/comments?path=posts/2008/10/new-post.md&name=Peter&text=Servus"
    
    @blog.store.load

    comments = @blog.comments_for(@posts[0].path)

    comments[0].should_not be_nil
    comments[0].name.should == 'Hans'
    comments[0].text.should == 'Hallo'

    comments[1].should_not be_nil
    comments[1].name.should == 'Peter'
    comments[1].text.should == 'Servus'
  end
  
end
