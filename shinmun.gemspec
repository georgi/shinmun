Gem::Specification.new do |s|
  s.name = 'shinmun'
  s.version = '0.5'
  s.summary = 'git-based blog engine'
  s.author = 'Matthias Georgi'
  s.email = 'matti.georgi@gmail.com'
  s.homepage = 'http://github.com/georgi/shinmun'  
  s.description = "git-based blog engine."
  s.bindir = 'bin'
  s.executables << 'shinmun'
  s.require_path = 'lib'
  s.add_dependency 'BlueCloth'
  s.add_dependency 'rubypants'
  s.add_dependency 'rack'
  s.add_dependency 'coderay'
  s.has_rdoc = true
  s.extra_rdoc_files = ['README.md']  
  s.files = %w{
README.md
Rakefile
assets/print.css
assets/styles.css
bin/shinmun
config.ru
lib/shinmun.rb
lib/shinmun/blog.rb
lib/shinmun/bluecloth_coderay.rb
lib/shinmun/comment.rb
lib/shinmun/handlers.rb
lib/shinmun/helpers.rb
lib/shinmun/post.rb
lib/shinmun/post_handler.rb
lib/shinmun/routes.rb
templates/index.rhtml
templates/page.rhtml
templates/404.rhtml
templates/_comments.rhtml
templates/category.rhtml
templates/_comment_form.rhtml
templates/post.rhtml
templates/index.rxml
templates/category.rxml
templates/archive.rhtml
templates/layout.rhtml
test/blog_spec.rb
test/post_spec.rb
}
end

