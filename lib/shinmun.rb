require 'rubygems'
require 'fileutils'
require 'erb'
require 'yaml'
require 'bluecloth'
require 'rubypants'
require 'rexml/document'
require 'time'

begin; require 'packr'; rescue LoadError; end
begin; require 'json'; rescue LoadError; end
begin; require 'redcloth'; rescue LoadError; end

require 'shinmun/cache'
require 'shinmun/post'
require 'shinmun/comment'
require 'shinmun/template'
require 'shinmun/helpers'
require 'shinmun/blog'

require 'shinmun/aggregations/audioscrobbler'
require 'shinmun/aggregations/delicious'
require 'shinmun/aggregations/flickr'
require 'shinmun/aggregations/fortythree'
