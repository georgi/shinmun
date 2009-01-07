require 'rubygems'
require 'fileutils'
require 'bluecloth'
require 'rubypants'
require 'coderay'
require 'kontrol'
require 'git_store'
require 'grit'

begin; require 'redcloth'; rescue LoadError; end

require 'shinmun/bluecloth_coderay'
require 'shinmun/helpers'
require 'shinmun/blog'
require 'shinmun/routes'
require 'shinmun/post'
require 'shinmun/comment'
require 'shinmun/post_handler'

require 'shinmun/aggregations/delicious'
require 'shinmun/aggregations/flickr'
