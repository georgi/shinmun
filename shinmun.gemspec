Gem::Specification.new do |s|
  s.name = 'shinmun'
  s.version = '0.4'
  s.date = '2008-04-13'
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
bin/shinmun
example/Rakefile
example/assets/images/favicon.ico
example/assets/images/loading.gif
example/assets/javascripts/1-jquery.min.js
example/assets/javascripts/2-jquery-form.min.js
example/assets/javascripts/3-comments.js
example/assets/javascripts/4-coderay.js
example/assets/print.css
example/assets/stylesheets/1-reset.css
example/assets/stylesheets/2-typo.css
example/assets/stylesheets/3-table.css
example/assets/stylesheets/4-article.css
example/assets/stylesheets/5-comments.css
example/assets/stylesheets/6-diff.css
example/assets/stylesheets/7-blog.css
example/config.ru
example/config/blog.yml
example/pages/about.md
example/templates/_comment_form.rhtml
example/templates/_comments.rhtml
example/templates/_pagination.rhtml
example/templates/archive.rhtml
example/templates/category.rhtml
example/templates/category.rxml
example/templates/index.rhtml
example/templates/index.rxml
example/templates/layout.rhtml
example/templates/page.rhtml
example/templates/post.rhtml
lib/shinmun.rb
lib/shinmun/aggregations/delicious.rb
lib/shinmun/aggregations/flickr.rb
lib/shinmun/blog.rb
lib/shinmun/bluecloth_coderay.rb
lib/shinmun/comment.rb
lib/shinmun/helpers.rb
lib/shinmun/post.rb
lib/shinmun/post_handler.rb
lib/shinmun/routes.rb
test/blog_spec.rb
test/post_spec.rb
test/templates/_comments.rhtml
test/templates/archive.rhtml
test/templates/category.rhtml
test/templates/category.rxml
test/templates/index.rhtml
test/templates/index.rxml
test/templates/layout.rhtml
test/templates/page.rhtml
test/templates/post.rhtml
}
end

