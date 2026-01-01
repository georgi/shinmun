Gem::Specification.new do |s|
  s.name = 'shinmun'
  s.version = '1.1.0'
  s.summary = 'file based blog engine'
  s.author = 'Matthias Georgi'
  s.email = 'matti.georgi@gmail.com'
  s.homepage = 'http://github.com/georgi/shinmun'  
  s.description = "file based blog engine."
  s.bindir = 'bin'
  s.executables << 'shinmun'
  s.require_path = 'lib'
  s.required_ruby_version = '>= 3.2.0'
  s.add_dependency 'kramdown', '~> 2.5'
  s.add_dependency 'rubypants'
  s.add_dependency 'rack', '>= 1.0'
  s.add_dependency 'rouge', '~> 4.0'
  s.add_dependency 'kontrol', '>= 0.3.1'
  s.extra_rdoc_files = ['README.md']  
  s.files = %w{
README.md
LICENSE
Rakefile
Gemfile
public/styles.css
bin/shinmun
config.ru
lib/shinmun.rb
lib/shinmun/blog.rb
lib/shinmun/kramdown_rouge.rb
lib/shinmun/comment.rb
lib/shinmun/helpers.rb
lib/shinmun/post.rb
lib/shinmun/routes.rb
templates/index.rhtml
templates/page.rhtml
templates/404.rhtml
templates/category.rhtml
templates/post.rhtml
templates/index.rxml
templates/archive.rhtml
templates/layout.rhtml
test/blog_spec.rb
test/post_spec.rb
}
end
