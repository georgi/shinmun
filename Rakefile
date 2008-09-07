require 'rubygems'

require 'rake'
require 'rake/clean'
require 'rake/rdoctask'
require 'rake/packagetask'
require 'rake/gempackagetask'
require 'fileutils'

spec = Gem::Specification.new do |s|
  s.name = "shinmun"
  s.version = `git describe`.strip.sub(/-.*/, '')
  s.platform = Gem::Platform::RUBY
  s.summary = "a small blog engine"
  
  s.description = <<-EOF
Shinmun is a blog engine, which renders text files using a markup
language like Markdown and a set of templates into static web
pages. It supports Categories, Archives and RSS Feeds. Commenting can
be done with some Javascript, PHP and a flat file JSON store.
EOF
  
  s.files = `git ls-files`.split("\n")
  s.bindir = 'bin'
  s.executables << 'shinmun'
  s.require_path = 'lib'
  s.add_dependency 'uuid', '>=2.0.0'
  s.add_dependency 'BlueCloth', '>=1.0.0'
  s.add_dependency 'rubypants', '>=0.2.0'
  s.has_rdoc = true
  s.extra_rdoc_files = ['README']
  
  s.author = 'Matthias Georgi'
  s.email = 'matti.georgi@gmail.com'
  s.homepage = 'http://shinmun.rubyforge.org'
  s.rubyforge_project = 'shinmun'
end

Rake::GemPackageTask.new(spec) do |p|
  p.gem_spec = spec
  p.need_tar = false
  p.need_zip = false
end

 
desc "Generate RDoc documentation"
Rake::RDocTask.new(:rdoc) do |rdoc|

  rdoc.options << '--line-numbers' << '--inline-source' <<
    '--main' << 'README' <<
    '--title' << 'Shinmun Documentation' <<
    '--charset' << 'utf-8'
  rdoc.rdoc_dir = "doc"
  rdoc.rdoc_files.include 'README'
  rdoc.rdoc_files.include('lib/shinmun.rb')
end
