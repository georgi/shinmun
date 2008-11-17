require 'rubygems'

require 'rake'
require 'rake/clean'
require 'rake/rdoctask'
require 'rake/packagetask'
require 'rake/gempackagetask'
require 'fileutils'

spec = Gem::Specification.new do |s|
  s.name = "shinmun"
  s.version = `git describe`
  s.platform = Gem::Platform::RUBY
  s.summary = "a small blog engine"
  
  s.description = <<-EOF
Shinmun is a blog engine, which renders text files using a markup
language like Markdown and a set of templates into either static web
pages or serving them over a rack adapter. Shinmun supports
categories, archives, rss feeds and commenting.
EOF
  
  s.files = `git ls-files`.split("\n").reject { |f| f.match /^pkg/ }
  s.bindir = 'bin'
  s.executables << 'shinmun'
  s.require_path = 'lib'
  s.add_dependency 'BlueCloth'
  s.add_dependency 'rubypants'
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
  Dir['lib/**/*.rb'].each do |file|
    rdoc.rdoc_files.include file
  end
end


task :pdoc => [:rdoc] do
  sh "rsync -avz doc/ mgeorgi@rubyforge.org:/var/www/gforge-projects/shinmun"
end

desc "Publish the release files to RubyForge."
task :release => [ :gem ] do
  require 'rubyforge'
  require 'rake/contrib/rubyforgepublisher'
 
  rubyforge = RubyForge.new
  rubyforge.configure
  rubyforge.login
  rubyforge.add_release('shinmun', 'shinmun', spec.version, "pkg/shinmun-#{spec.version}.gem")
end
