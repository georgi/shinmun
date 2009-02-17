Gem::Specification.new do |s|
  s.name = 'shinmun'
  s.version = '0.3.7'
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
example/pages/about.md
example/Rakefile
example/templates
example/templates/index.rhtml
example/templates/page.rhtml
example/templates/_comments.rhtml
example/templates/category.rhtml
example/templates/_comment_form.rhtml
example/templates/post.rhtml
example/templates/index.rxml
example/templates/admin
example/templates/admin/commit.rhtml
example/templates/admin/posts.rhtml
example/templates/admin/pages.rhtml
example/templates/admin/edit.rhtml
example/templates/admin/commits.rhtml
example/templates/category.rxml
example/templates/_pagination.rhtml
example/templates/layout.rhtml
example/assets/images/favicon.ico
example/assets/images/loading.gif
example/assets/stylesheets/7-diff.css
example/assets/stylesheets/8-blog.css
example/assets/stylesheets/6-comments.css
example/assets/stylesheets/5-coderay.css
example/assets/stylesheets/1-reset.css
example/assets/stylesheets/3-table.css
example/assets/stylesheets/4-article.css
example/assets/stylesheets/2-typo.css
example/assets/print.css
example/assets/wmd/images/wmd.png
example/assets/wmd/images/bg-fill.png
example/assets/wmd/images/italic.png
example/assets/wmd/images/h1.png
example/assets/wmd/images/wmd-on.png
example/assets/wmd/images/undo.png
example/assets/wmd/images/link.png
example/assets/wmd/images/bold.png
example/assets/wmd/images/ul.png
example/assets/wmd/images/img.png
example/assets/wmd/images/blockquote.png
example/assets/wmd/images/code.png
example/assets/wmd/images/hr.png
example/assets/wmd/images/bg.png
example/assets/wmd/images/separator.png
example/assets/wmd/images/redo.png
example/assets/wmd/images/ol.png
example/assets/wmd/showdown.js
example/assets/wmd/wmd-plus.js
example/assets/wmd/wmd-base.js
example/assets/wmd/wmd.js
example/assets/javascripts/2-jquery-form.min.js
example/assets/javascripts/1-jquery.min.js
example/assets/javascripts/4-coderay.js
example/assets/javascripts/3-comments.js
example/config.ru
example/config/blog.yml
lib/shinmun.rb
lib/shinmun/aggregations/delicious.rb
lib/shinmun/aggregations/flickr.rb
lib/shinmun/blog.rb
lib/shinmun/routes.rb
lib/shinmun/bluecloth_coderay.rb
lib/shinmun/comment.rb
lib/shinmun/helpers.rb
lib/shinmun/post.rb
lib/shinmun/post_handler.rb
test/templates/index.rhtml
test/templates/page.rhtml
test/templates/_comments.rhtml
test/templates/category.rhtml
test/templates/post.rhtml
test/templates/index.rxml
test/templates/category.rxml
test/templates/archive.rhtml
test/templates/layout.rhtml
test/blog_spec.rb
test/post_spec.rb
}
end

