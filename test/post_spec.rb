$:.unshift '../lib'

require 'shinmun'

describe Shinmun::Post do

  BODY = "Patroon is a template engine written in Javascript in about 100 lines
of code. It takes existing DOM nodes annotated with CSS classes and
expand a data object according to simple rules. Additionally you may
use traditional string interpolation inside attribute values and text
nodes."
  
  POST = <<-END
--- 
category: Javascript
date: 2008-09-09
tags: template, engine, json
title: Patroon - a Javascript Template Engine
---
#{BODY}
END

  it "should infer the name from title" do
    post = Shinmun::Post.new(:title => 'Patroon - a Javascript Template Engine')
    post.name.should == 'patroon-a-javascript-template-engine'
  end

  it "should return tags as list" do
    post = Shinmun::Post.new
    post.tags = 'a,b,c,d'
    post.tag_list.should == ['a', 'b', 'c', 'd']
  end

  it "should infer path from date and name for posts" do
    post = Shinmun::Post.new
    post.name = 'post'
    post.date = Date.new(2010,1,1)
    post.path.should == 'posts/2010/1/post.md'
  end

  it "should infer path from name for pages" do
    post = Shinmun::Post.new
    post.name = 'page'
    post.path.should == 'pages/page.md'
  end

  it "should set type, name and mtime upon loading a post" do
    File.stub!(:mtime).and_return(Time.local(2010, 1, 1))
    File.stub!(:read).and_return(POST)
    
    post = Shinmun::Post.new(:file => 'posts/2010/01/a-post.md')
    post.load
    post.type.should == 'md'
    post.name.should == 'a-post'
    post.mtime.should == Time.local(2010, 1, 1)
  end

  it "should detect a changed file" do
    File.should_receive(:mtime).with('file').and_return(Time.local(2009, 1, 1))
    File.should_receive(:mtime).with('file').and_return(Time.local(2010, 1, 1))

    post = Shinmun::Post.new
    post.file = 'file'
    post.mtime = Time.local(2009, 1, 1)
    post.changed?.should be_false
    post.changed?.should be_true
  end    

  it "should parse the yaml header" do
    post = Shinmun::Post.new(:type => 'md')
    post.parse(POST)
    post.title.should == 'Patroon - a Javascript Template Engine'
    post.category.should == 'Javascript'
    post.date.should == Date.new(2008,9,9)
    post.tags.should == 'template, engine, json'
    post.body.chop == BODY
  end

  it "should not parse the yaml header if not present" do
    post = Shinmun::Post.new
    post.parse('just the body')
    post.body.should == 'just the body'
  end

  it "should transform the body" do
    post = Shinmun::Post.new(:title => 'test', :body => '**bold**')
    post.body_html.should == '<p><strong>bold</strong></p>'
  end

  it "should transform according to type" do
    post = Shinmun::Post.new(:title => 'test', :type => 'html', :body => '**bold**')
    post.body_html.should_not == '<p><strong>bold</strong></p>'
  end

end
