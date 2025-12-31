require 'kontrol'

describe Kontrol::Router do

  before :each do
    @router = Kontrol::Router.new
  end

  def request(env)
    Rack::Request.new(env)
  end
  
  it "should find a route" do
    @router.test '/test'
    route = @router.__find__(:test)

    route.name.should == :test
    route.pattern.should == '/test'
  end

  it "should recognize a route" do
    request = request('PATH_INFO' => '/test')    
    
    @router.test '/test'
    route, match = @router.__recognize__(request)

    route.name.should == :test
    route.pattern.should == '/test'
  end

  it "should recognize routes in right order" do
    request = request('PATH_INFO' => '/test')
    
    @router.root '/'
    @router.test '/test'
    
    route, match = @router.__recognize__(request)

    route.name.should == :root
    route.pattern.should == '/'
  end
  
  it "should not recognize a not matching route" do
    request = request('PATH_INFO' => '/test')
    
    @router.root '/other'
    
    route, match = @router.__recognize__(request)

    route.should be_nil
  end

end
