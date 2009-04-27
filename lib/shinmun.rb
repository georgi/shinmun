require 'rubygems'
require 'fileutils'
require 'bluecloth'
require 'rubypants'
require 'coderay'
require 'kontrol'
require 'git_store'

begin; require 'redcloth'; rescue LoadError; end

require 'shinmun/bluecloth_coderay'
require 'shinmun/helpers'
require 'shinmun/handlers'
require 'shinmun/blog'
require 'shinmun/routes'
require 'shinmun/post'
require 'shinmun/comment'

require 'shinmun/aggregations/delicious'
require 'shinmun/aggregations/flickr'
