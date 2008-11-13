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
pages. Shinmun supports categories, archives and RSS feeds. Commenting
is supported through a PHP script and flat file storage.
EOF
  
  s.files = `git ls-files`.split("\n").reject { |f| f.match /^pkg/ }
  s.bindir = 'bin'
  s.executables << 'shinmun'
  s.require_path = 'lib'
  s.add_dependency 'BlueCloth'
  s.add_dependency 'RedCloth'
  s.add_dependency 'rubypants'
  s.add_dependency 'packr'
  s.has_rdoc = true
  s.extra_rdoc_files = ['README.md']
  
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
  rdoc.rdoc_files.include 'README.md'
  rdoc.rdoc_files.include('lib/shinmun.rb')
end


task :push => [:rdoc] do
  sh "rsync -avz doc/ mgeorgi@rack.rubyforge.org:/var/www/gforge-projects/shinmun"
end
