require 'shinmun'

describe Shinmun::Post do

  HEADER = <<-END
--- 
category: Javascript
date: 2008-09-09
tags: template, engine, json

END

  POST_MD = <<END
Patroon - a Javascript Template Engine
======================================

Patroon is a template engine written in Javascript in about 100 lines
of code. It takes existing DOM nodes annotated with CSS classes and
expand a data object according to simple rules. Additionally you may
use traditional string interpolation inside attribute values and text
nodes.
END

  POST_HTML = <<END
<h1>Patroon - a Javascript Template Engine</h1>

Patroon is a template engine written in Javascript in about 100 lines
of code. It takes existing DOM nodes annotated with CSS classes and
expand a data object according to simple rules. Additionally you may
use traditional string interpolation inside attribute values and text
nodes.
END

  it 'should parse and dump in the same way' do
    Shinmun::Post.new(:type => 'md').parse(HEADER + POST_MD).dump.should == (HEADER + POST_MD)
    Shinmun::Post.new(:type => 'html').parse(HEADER + POST_HTML).dump.should == (HEADER + POST_HTML)
  end

  it 'should parse a Markdown title' do
    Shinmun::Post.new(:type => 'md').parse_title(POST_MD)[0].should == 'Patroon - a Javascript Template Engine'
    Shinmun::Post.new(:type => 'html').parse_title(POST_HTML)[0].should == 'Patroon - a Javascript Template Engine'
  end

  it "should parse the yaml header" do
    post = Shinmun::Post.new(:type => 'md').parse(HEADER + POST_MD)
    post.category.should == 'Javascript'
    post.date.should == Date.new(2008,9,9)
    post.tags.should == 'template, engine, json'
    post.tag_list.should == ['template', 'engine', 'json']
  end

end
