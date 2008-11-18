require 'rubygems'
require 'fileutils'
require 'erb'
require 'yaml'
require 'time'

require 'bluecloth'
require 'rubypants'
require 'coderay'
require 'shinmun/bluecloth_coderay'

begin; require 'redcloth'; rescue LoadError; end
begin; require 'packr'; rescue LoadError; end

require 'shinmun/cache'
require 'shinmun/post'
require 'shinmun/comment'
require 'shinmun/template'
require 'shinmun/helpers'
require 'shinmun/blog'

require 'shinmun/aggregations/delicious'
require 'shinmun/aggregations/flickr'
