#! /usr/bin/env ruby

$:.unshift File.dirname(__FILE__) + '/../lib'

require 'shinmun'

Shinmun::Blog.new.write_all
