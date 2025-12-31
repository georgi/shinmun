require 'kontrol'
require 'rack/mock'

describe Kontrol::Application do

  before do
    @class = Class.new(Kontrol::Application)
    @app = @class.new
    @request = Rack::MockRequest.new(@app)
    
    def @app.load_template(file)
      if file == "layout.rhtml"
        ERB.new '<html><%= @content %></html>'
      else
        ERB.new '<p><%= @body %></p>'
      end
    end
  end

  def get(*args)
    @request.get(*args)
  end
  
  def map(&block)
    @class.map(&block)
  end

  it "should do simple pattern matching" do
    map do      
      one '/one' do
        response.body = 'one'
      end
      
      two '/two' do
        response.body = 'two'
      end
    end

    get("/one").body.should == 'one'
    get("/two").body.should == 'two'
  end

  it "should have a router" do
    map do
      root '/'
    end

    @class.router.should_not be_nil
  end
  
  it "should generate paths" do
    map do
      root '/'
      about '/about'
      page '/page/(.*)'
    end

    @app.root_path.should == '/'
    @app.about_path.should == '/about'
    @app.page_path('world').should == '/page/world'
  end

  it "should redirect" do
    map do
      root '/' do
        redirect 'x'
      end
    end

    get('/')['Location'].should == 'x'
    get('/').status.should == 301
  end

  it "should respond with not modified" do
    map do
      assets '/assets/(.*)' do
        script = "script"
        if_none_match(etag(script)) do
          text script
        end
      end
    end

    get("/assets/test.js").body.should == 'script'
    
    etag = get("/assets/file")['Etag']    
    get("/assets/file", 'HTTP_IF_NONE_MATCH' => etag).status.should == 304
  end

  it "should render text" do
    map do
      index '/' do
        text "Hello"
      end
    end

    get('/').body.should == 'Hello'
    get('/')['Content-Length'].should == '5'
  end

  it "should render no layout" do
    map do
      index '/' do
        render 'index.rhtml', :body => 'BODY', :layout => false
      end
    end

    get('/').body.should == '<p>BODY</p>'
  end

  it "should render templates" do
    map do
      index '/' do
        render 'index.rhtml', :body => 'BODY'
      end
    end

    get('/').body.should == '<html><p>BODY</p></html>'
  end
  
end
