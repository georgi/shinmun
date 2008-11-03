Shinmun, a small and beautiful blog engine
==========================================

### Intro

Shinmun is a **minimalist blog engine**. You just write posts as text files,
render them to static files and push your blog to your server.

This allows you to write posts in your favorite editor like Emacs or
VI and use a VCS like git.

Your layout can be customized by a set of *ERB templates*. These
templates have access to `Post` objects and *helper methods* so that
anybody who knows *Rails* should feel comfortable with it.

Shinmun has some common features of blog engines like:

* Index summary page
* Category summary page
* Archive pages for each month
* RSS feeds for index and category pages
* Builtin webserver for realtime rendering
* Compression of javascript files with Packr
* AJAX comment system with PHP JSON file storage
* Integration of the WMD-Markdown Editor for comments

### Quickstart

Install the gem by typing:
    gem install shinmun

Issue the following commands and the output will go to the public
folder:

    cd example
    ../bin/shinmun

### Writing Posts

Posts can be created by using the `shinmun` command inside your blog folder:

    shinmun new 'The title of the post'

Shinmun will then create a post file in the right place, for example
in `posts/2008/9/the-title-of-the-post.md`. After creating you will
probably open the file, set the category and start writing your new
article.

After finishing your post, you may run `shinmun render` and the output
will be rendered to the *public* folder.

It is more convenient to use the builtin webserver. Just run `shinmun
server` and go to `http://localhost:3000` and you will see your blog
served in realtime. Just change and save any of your posts and you
will see the new output in your browser.

By issuing the `shinmun push` command your blog will be pushed to your
server using rsync. This works only, if you define the blog_repository
variable inside blog.yml. It should contain something like
`user@myhost.com:/var/www/my-site/`.


### Post Format

Each blog post is just a text file with an optional header section and
a markup body, which are separated by a newline. Normally you don't
have to worry about the post format, if you create posts with the
`shinmun new` command.

The **first line** of the header should start with 3 dashes as usual
for a YAML document.

The title of your post will be parsed from your first heading
according to the document type. Shinmun will try to figure out the
title for Markdown, Textile and HTML files.

The yaml header may have following attributes:

* `date`: post will show up in blog page and archive pages
* `category`: post will show up in the defined category page
* `guid`: will be set automatically by Shinmun

Posts without a date are by definition static pages.

Example post:

<pre>

    --- 
    category: Ruby
    date: 2008-09-05
    guid: 7ad04f10-5dd6-012b-b53c-001a92975b89
     
    BlueCloth, a Markdown library
    =============================

    This is the summary, which is by definition the first paragraph of the
    article. The summary shows up in category listings or the index listing.

</pre>

The guid should never change, as it will be you used for identifying
posts for comments.


### Directory layout

* Your **assets** are in the `assets` folder, which gets copied to the
  public folder in the render step. You will probably have folders like
  `assets/images`, `assets/stylesheets`, `asstes/javascripts`.

* Your **posts** reside in the `posts` folder sorted by year/month.

* Your **pages** are located in the `pages` folder.

* The *home page* of your blog is defined in `pages/index.rhtml` and
  may be customized.

* The **output** will be rendered to the `public` folder.

* **Template** files are in the `templates` folder.

* The **properties of your blog** are defined in `config/blog.yml`

* Archive pages will be rendered to files like `public/2008/9/index.html`.

* Category pages will be rendered to files like `public/categories/ruby.html`.


An example tree:

    + assets
      + images
      + stylesheets
      + javascripts      
    + config
      + blog.yml
    + pages
      + about.md
      + index.rhtml
    + posts
      + 2007
      + 2008
        + 9
          + my-article.md
    + templates
      + feed.rxml
      + layout.rhtml
      + page.rhtml  
      + post.rhtml  
      + posts.rhtml


The output will look like this:

    + public
      + index.html
      + about.html
      + categories
        + emacs.html
        + ruby.html
      + 2007   
      + 2008
        + 9
          + my-article.html
      + images
      + stylesheets
      + javascripts


### Config file

The configuration of the blog system consists of some variables
encoded as yaml file:

    * blog_title: the title of your blog, used for rss

    * blog_description: used for rss

    * blog_language: used for rss

    * blog_author: used for rss, acts also as fallback for the blog.author variable

    * blog_url: used for rss

    * blog_repository: path for rsync, used for `shinmun push` command

    * base_path: if your blog should not be rendered to your site
      root, you can define a sub path here (like `blog`)

    * images_path: used for templates helper, defaults to `images`

    * javascripts_path: used for templates helper, defaults to `javascripts`

    * stylesheets_path: used for templates helper, defaults to `stylesheets`

    * pack_javascripts: a list of scripts to be compressed to a file
      named `all.js` Note that you define a yaml array here without
      file extensions, so it should like `[jquery, jquery-form]`

    * pack_stylesheets: a list of files to be concatenated to a file
      named `all.css` Note that you define a yaml array here without
      file extensions , so it should like `[reset, grid]`


### Layout

Layout and templates are rendered by *ERB*.  The layout is defined in
`layout.rhtml`. The content will be provided in the variable
`@content`. A minimal example:

    <html>
      <head>
        <title><%= @blog_title %></title>
        <%= stylesheet_link_tag 'style' %>
      </head>
      <body>
         <%= @content %>
      </body>
     </html>


### Helpers

There are also helper methods, which work the same way like the *Rails*
helpers. The most important ones are these:
    
* `stylesheet_link_tag(*names)` links a stylesheet with a timestamp

* `javascript_tag(*names)` includes a javascript with a timestamp

* `image_tag(src, options = {})` renders an image tag

* `link_to(text, path, options = {})` renders a link

Stylesheets, javascripts and images should be included by using theses
helpers. The helper methods will include a timestamp of the
modification time as `querystring`, so that the browser will fetch the
new resource if it has been changed.

If you want to define your own helpers, just define a file named
`templates/helpers.rb` with a module named `Shinmun::Helpers. This
module will be included into the `Shinmun::Template` class.


### Post Template

The attributes of a post are accessible as instance variables in a template:

    <div class="article">    

      <div class="date">
        <%= date @date %>
      </div>
     
      <h2><%= @title %></h2>  
     
      <%= @body %>
     
      <h3>Comments</h3>

      <!-- Here you may put my commenting system -->
    </div>



### RSS Feeds

Feeds will be rendered by one *ERB template*. Some of the variables
have been read from the `blog.yml`, like `@blog_title`, other variables
have been determined by the engine like `@posts` and `@category`.

    <?xml version="1.0" encoding="utf-8"?>
    <rss version="2.0"> 
      <channel>
        <title><%= @category ? @blog_title + ' - ' + @category : @blog_title %></title>
        <link><%= @blog_url %></link>
        <description><%= @category ? 'Category ' + @category : @blog_description %></description>
        <language><%= @blog_language %></language>
        <copyright><%= @blog_author %></copyright>
        <pubDate><%= rfc822 Time.now %></pubDate>
        <% for post in @posts %>
          <item>
            <title><%= post.title %></title>
            <description><%= post.text_summary %></description>
            <link><%= post.link %></link>
            <author><%= @blog_author %></author>
            <guid><%= post.guid %></guid>
            <pubDate><%= rfc822 post.date %></pubDate>
          </item>
        <% end %>
      </channel> 
    </rss>

### Packr Support

If you set the variables `pack_javascripts` or `pack_stylesheets`,
Shinmun will create the files `all.js` or `all.css` automatically
on rendering (even on each request of the webserver).

The Javascript will be compressed with Packr and for performance
reasons, minified versions for each of your javascripts will be
created automatically in `assets/javascripts`.

The stylesheets will be just concatenated to one file named `all.css`.


### Commenting System

As I am not willing to build up a whole Rails stack for a single blog,
I was looking for a simple storage for comments. I really like the
JSON format. It works seamlessly with Javascript libraries and can be
serialized and deserialized from almost any language.

Read about my [lightweight commenting system][2].


### Download

Simply install the gem:

    gem install shinmun


Download or fork the package at my [github repository][1]



[1]: http://github.com/georgi/shinmun/tree/master
[2]: commenting-system-with-lightweight-json-store.html
