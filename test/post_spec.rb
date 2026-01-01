$:.unshift '../lib'

require 'shinmun'

RSpec.describe Shinmun::Post do

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
    expect(post.name).to eq('patroon-a-javascript-template-engine')
  end

  it "should return tags as list" do
    post = Shinmun::Post.new
    post.tags = 'a,b,c,d'
    expect(post.tag_list).to eq(['a', 'b', 'c', 'd'])
  end

  it "should infer path from date and name for posts" do
    post = Shinmun::Post.new
    post.name = 'post'
    post.date = Date.new(2010,1,1)
    expect(post.path).to eq('posts/2010/1/post.md')
  end

  it "should infer path from name for pages" do
    post = Shinmun::Post.new
    post.name = 'page'
    expect(post.path).to eq('pages/page.md')
  end

  it "should set type, name and mtime upon loading a post" do
    allow(File).to receive(:mtime).and_return(Time.local(2010, 1, 1))
    allow(File).to receive(:read).and_return(POST)
    
    post = Shinmun::Post.new(:file => 'posts/2010/01/a-post.md')
    post.load
    expect(post.type).to eq('md')
    expect(post.name).to eq('a-post')
    expect(post.mtime).to eq(Time.local(2010, 1, 1))
  end

  it "should detect a changed file" do
    expect(File).to receive(:mtime).with('file').and_return(Time.local(2009, 1, 1))
    expect(File).to receive(:mtime).with('file').and_return(Time.local(2010, 1, 1))

    post = Shinmun::Post.new
    post.file = 'file'
    post.mtime = Time.local(2009, 1, 1)
    expect(post.changed?).to be false
    expect(post.changed?).to be true
  end    

  it "should parse the yaml header" do
    post = Shinmun::Post.new(:type => 'md')
    post.parse(POST)
    expect(post.title).to eq('Patroon - a Javascript Template Engine')
    expect(post.category).to eq('Javascript')
    expect(post.date).to eq(Date.new(2008,9,9))
    expect(post.tags).to eq('template, engine, json')
    expect(post.body.strip).to eq(BODY)
  end

  it "should not parse the yaml header if not present" do
    post = Shinmun::Post.new
    post.parse('just the body')
    expect(post.body).to eq('just the body')
  end

  it "should transform the body" do
    post = Shinmun::Post.new(:title => 'test', :body => '**bold**')
    expect(post.body_html.strip).to eq('<p><strong>bold</strong></p>')
  end

  it "should transform according to type" do
    post = Shinmun::Post.new(:title => 'test', :type => 'html', :body => '**bold**')
    expect(post.body_html).not_to eq('<p><strong>bold</strong></p>')
  end

end
