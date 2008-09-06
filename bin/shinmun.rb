#! /usr/bin/env ruby

$:.unshift File.dirname(__FILE__) + '/../lib'

require 'shinmun'

Shinmun::Blog.new(ARGV[0] || Dir.pwd).write_all
