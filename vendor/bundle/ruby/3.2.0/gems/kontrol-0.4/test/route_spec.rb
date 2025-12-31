require 'kontrol'

describe Kontrol::Route do

  it "should recognize a request" do
    route = Kontrol::Route.new(:test, "/test", nil, nil)
    request = Rack::Request.new('PATH_INFO' => '/test')

    match = route.recognize(request)

    match.should_not be_nil
    match[0].should == '/test'
  end

  it "should recognize a request by options" do
    route = Kontrol::Route.new(:test, "/test", { :request_method => 'GET' }, nil)
    request = Rack::Request.new('PATH_INFO' => '/test', 'REQUEST_METHOD' => 'GET')

    match = route.recognize(request)

    match.should_not be_nil
    match[0].should == '/test'
  end

  it "should recognize a request with groups" do
    route = Kontrol::Route.new(:test, "/test/(.*)/(.*)", nil, nil)
    request = Rack::Request.new('PATH_INFO' => '/test/me/here')

    match = route.recognize(request)

    match.should_not be_nil
    match[0].should == '/test/me/here'
    match[1].should == 'me'
    match[2].should == 'here'
  end

  it "should generate a path" do
    route = Kontrol::Route.new(:test, "/test", nil, nil)

    route.generate.should == '/test'
  end
  
  it "should generate a path with groups" do
    route = Kontrol::Route.new(:test, "/test/(.*)/me/(\d\d)", nil, nil)

    route.generate(1, 22).should == '/test/1/me/22'
  end

end

