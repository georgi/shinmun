require 'fileutils'
require 'yaml'
require 'date'
require 'kramdown'
require 'rubypants'
require 'rouge'
require 'kontrol'

begin; require 'redcloth'; rescue LoadError; end

require_relative 'shinmun/kramdown_rouge'
require_relative 'shinmun/typescript_embed'
require_relative 'shinmun/helpers'
require_relative 'shinmun/blog'
require_relative 'shinmun/routes'
require_relative 'shinmun/post'
require_relative 'shinmun/comment'
require_relative 'shinmun/exporter'
require_relative 'shinmun/ai_assistant'
