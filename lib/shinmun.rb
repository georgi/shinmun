require 'rubygems'
require 'fileutils'
require 'erb'
require 'yaml'
require 'uuid'
require 'bluecloth'
require 'redcloth'
require 'rubypants'
require 'rexml/document'

require 'shinmun/post'
require 'shinmun/template'
require 'shinmun/blog'
require 'shinmun/server'

# A small and beautiful blog engine.
module Shinmun

  # strip html tags from string
  def self.strip_tags(html)
    REXML::Document.new(html).each_element('.//text()').join
  end

  def self.urlify(string)
    string.downcase.gsub(/[ -]+/, '-').gsub(/[^-a-z0-9_]+/, '')
  end

end
