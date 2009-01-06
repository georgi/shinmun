require 'shinmun'

describe Shinmun::Post do

  POST = <<-END
--- 
category: Javascript
date: 2008-09-09
tags: template, engine, json
title: Patroon - a Javascript Template Engine
---
Patroon is a template engine written in Javascript in about 100 lines
of code. It takes existing DOM nodes annotated with CSS classes and
expand a data object according to simple rules. Additionally you may
use traditional string interpolation inside attribute values and text
nodes.
END

  it 'should parse and dump in the same way' do
    Shinmun::Post.new(:type => 'md').parse(POST).dump.should == (POST)
  end

  it "should parse the yaml header" do
    post = Shinmun::Post.new(:type => 'md').parse(POST)
    post.title.should == 'Patroon - a Javascript Template Engine'
    post.category.should == 'Javascript'
    post.date.should == Date.new(2008,9,9)
    post.tags.should == 'template, engine, json'
    post.tag_list.should == ['template', 'engine', 'json']
  end

end
