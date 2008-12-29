Gem::Specification.new do |s|
  s.name = 'shinmun'
  s.version = '0.3.2'
  s.date = '2008-12-17'
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
.gitignore
LICENSE
README.md
Rakefile
bin/shinmun
example/Rakefile
example/assets/images/favicon.ico
example/assets/images/loading.gif
example/assets/javascripts/coderay.js
example/assets/javascripts/comments.js
example/assets/javascripts/jquery-form.min.js
example/assets/javascripts/jquery.min.js
example/assets/stylesheets/article.css
example/assets/stylesheets/coderay.css
example/assets/stylesheets/comments.css
example/assets/stylesheets/form.css
example/assets/stylesheets/list.css
example/assets/stylesheets/print.css
example/assets/stylesheets/reset.css
example/assets/stylesheets/style.css
example/assets/stylesheets/table.css
example/assets/stylesheets/typo.css
example/assets/wmd/images/bg-fill.png
example/assets/wmd/images/bg.png
example/assets/wmd/images/blockquote.png
example/assets/wmd/images/bold.png
example/assets/wmd/images/code.png
example/assets/wmd/images/h1.png
example/assets/wmd/images/hr.png
example/assets/wmd/images/img.png
example/assets/wmd/images/italic.png
example/assets/wmd/images/link.png
example/assets/wmd/images/ol.png
example/assets/wmd/images/redo.png
example/assets/wmd/images/separator.png
example/assets/wmd/images/ul.png
example/assets/wmd/images/undo.png
example/assets/wmd/images/wmd-on.png
example/assets/wmd/images/wmd.png
example/assets/wmd/showdown.js
example/assets/wmd/wmd-base.js
example/assets/wmd/wmd-plus.js
example/assets/wmd/wmd.js
example/config.ru
example/config/aggregations.yml
example/config/assets.yml
example/config/blog.yml
example/map.rb
example/pages/about.md
example/password
example/templates/_comment_form.rhtml
example/templates/_comments.rhtml
example/templates/_pagination.rhtml
example/templates/admin/commit.rhtml
example/templates/admin/commits.rhtml
example/templates/admin/edit.rhtml
example/templates/admin/pages.rhtml
example/templates/admin/posts.rhtml
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
templates/_comments.rhtml
templates/archive.rhtml
templates/category.rhtml
templates/category.rxml
templates/index.rhtml
templates/index.rxml
templates/layout.rhtml
templates/page.rhtml
templates/post.rhtml
test/blog_spec.rb
test/map.rb
}
end

