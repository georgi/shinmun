Shinmun, a small and beautiful blog engine
==========================================

### Quickstart

Issue the following commands and the output will go to the public
folder:

    cd example
    ../bin/shinmun


### Intro

Shinmun is a **minimalist blog engine**. You just write posts as *text
files*, render them to *static files* and push your blog to your
*server*.

This allows you to write posts in your favorite editor like *Emacs* or
*vi* and use a *Version Control System* like *git*.

Your layout can be customized by set of *ERB templates*. These
templates have access to `Post` objects and *helper methods* so that
anybody who knows *Rails* should feel comfortable with it.

Shinmun has some common features of blog engines like:

* Index summary page
* Category summary page
* Archive pages for each month
* RSS feeds for index and category pages
* AJAX comment system with PHP JSON file storage
* Integration of the WMD-Markdown Editor for comments


### Blog Posts

Each blog post is just a text file with an optional header section and
a markup body, which are separated by a newline. The **first line** of
the body becomes the title of the post. So this is important not to
mess up.

The header may have following attributes:

* `date`: post will show up in blog page and archive pages
* `category`: post will show up in the defined category page
* `guid`: will be set automatically by Shinmun

Posts without a date are by definition static pages.

Example post:

    --- 
    category: Ruby
    date: 2008-09-05
    guid: 7ad04f10-5dd6-012b-b53c-001a92975b89
     
    BlueCloth, a Markdown library
    This is the summary, which is by definition the first paragraph of the
    article. The summary shows up in category listings or the index listing.


The guid should never change, as it will be you used for identifying
posts for comments.


### Directory layout

All your posts will be in the `posts` folder.

All the output will go to the `public` folder.

Template files wille be searched in the `templates` folder.


* The blog description, base url and the category list is in a file
  called `posts/blog.yml`

* Posts **must** be put into folders by date. `my-article.md` is in the
  folder 9 (September) of the year 2008. Posts are distinguished from
  pages by having a date attribute.

* Pages can be put anywhere, like `about.md`

* Static files *should* be put into the directories `public/images`,
  `public/stylesheets`, `public/javascripts`. This is because the link
  helper methods work like the Rails helpers. Links will get a
  timestamp, so that caching will work correctly.

* Category pages will be rendered into the `public/categories` folder.

* The *home page* of your blog will go to `public/index`.

An example tree:

    + posts
      + blog.yml
      + about.md
      * 2007
        + 2008
          + 9
            + my-article.md

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

    + templates
      + feed.rxml
      + layout.rhtml
      + page.rhtml  
      + post.rhtml  
      + posts.rhtml
 

### Layout

Layout and templates are rendered by good old *ERB*.  The layout will
be defined by the `layout.rhtml` template. The content will be
provided in the variable `@content`. A minimal example would be:

    <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
    <html xmlns="http://www.w3.org/1999/xhtml">
      <head>
        <title><%= @blog_title %> - <%= @title %></title>
        <meta http-equiv="Content-Language" content=<%= @blog_language $>" />
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <%= stylesheet_link_tag 'style' %>
      </head>
      <body>
         <%= @content %>
      </body>
     </html>

### Helpers

There are also helper methods, which work the same way like the *Rails*
helpers. The most important ones are these:
    
    * stylesheet_link_tag(*names):      
    * javascript_tag(*names)
    * image_tag(src, options = {})
    * link_to(text, path, options = {})

Stylesheets, javascripts and images should be included by using theses
helpers. The helper methods will include a timestamp of the
modification time as `querystring`, so that the browser will fetch the
new resource if it has been changed.


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
have been determined by the blog like `@posts` and `@category`.

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


### JSON store in PHP

As I am not willing to build up a whole Rails stack for a single blog,
I was looking for a simple storage for comments. I really like the
JSON format. It works seamlessly with Javascript libraries and can be
serialized and deserialized from almost any language.

Read about my [lightweight commenting system][2].


### Download

Download the package at my [github repository][1]

[1]: http://github.com/georgi/shinmun/tree/master
[2]: http://www.matthias-georgi.de/2008/9/commenting-system-with-lightweight-json-store.html
