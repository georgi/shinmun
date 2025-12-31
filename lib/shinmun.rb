require 'fileutils'
require 'yaml'
require 'date'
require 'bluecloth'
require 'rubypants'
require 'coderay'
require 'kontrol'

begin; require 'redcloth'; rescue LoadError; end

require_relative 'shinmun/bluecloth_coderay'
require_relative 'shinmun/helpers'
require_relative 'shinmun/blog'
require_relative 'shinmun/routes'
require_relative 'shinmun/post'
require_relative 'shinmun/comment'
