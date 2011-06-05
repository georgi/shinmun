$:.unshift '../../kontrol/lib'

require 'rubygems'
require 'fileutils'
require 'bluecloth'
require 'rubypants'
require 'coderay'
require 'kontrol'

begin; require 'redcloth'; rescue LoadError; end

require 'shinmun/bluecloth_coderay'
require 'shinmun/helpers'
require 'shinmun/blog'
require 'shinmun/routes'
require 'shinmun/post'
require 'shinmun/comment'
