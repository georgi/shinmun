Shinmun, a small and beautiful blog engine
==========================================

Shinmun is a **minimalist blog engine**. You just write posts as text
files and serve your blog via rack handler or static files.

This allows you to write posts in your favorite editor like Emacs or
VI and use a VCS like git.

Your layout can be customized by a set of *ERB templates*. These
templates have access to `Post` objects and *helper methods* so that
anybody who knows *Rails* should feel comfortable with it.


### Features

* Index listing
* Category listing
* Archive listings for each month
* RSS feeds for index and category pages
* Rack handler for realtime rendering
* Compression of javascript files with PackR
* Included syntax highlighting through `highlight.js`
* AJAX comment system with Markdown preview


### Quickstart

Install the necessary gems:

    gem install shinmun rack packr

Download and extract the example blog from my [github repository][3].

Issue the following commands:

    cd shinmun-example
    rackup

Now browse to the following url and you will see a minimal example
blog: 

    http://localhost:9292


### Writing Posts

Posts can be created by using the `shinmun` command inside your blog
folder:

    shinmun new 'The title of the post'

Shinmun will then create a post file in the right place, for example
in `posts/2008/9/the-title-of-the-post.md`. After creating you will
probably open the file, set the category and tags and start writing
your new article.


### Post Format

Each blog post is just a text file with an header section and a markup
body, which are separated by a newline.

The **first line** of a post should consist of 3 dashes to mark the
YAML header.

The title of your post will be parsed from your first heading
according to the document type. Shinmun will try to figure out the
title for Markdown, Textile and HTML files.

The yaml header may have following attributes:

* `title`: if you have no title inside the markup, you have to define it here
* `date`: needed for chronological order and for archive pages
* `category`: needed for category pages
* `tags`: used to determine similar posts

Example post:

<pre>

    --- 
    date: 2008-09-05
    category: Ruby
    tags: bluecloth, markdown, ruby
     
    BlueCloth, a Markdown library
    =============================

    This is the summary, which is by definition the first paragraph of the
    article. The summary shows up in category listings or the index listing.

</pre>



### Directory layout

* `assets`: like images, stylesheets and javascripts

* `comments`: comments stored as yaml files

* `config`: configuration of blog, aggregations, assets and categories

* `posts`: post files sorted by year/month.

* `pages`: contains static pages

* `templates`: ERB templates for layout, posts and others


An example tree:

    + assets
      + images
      + stylesheets
      + javascripts      
    + config
      + aggregations.yml
      + assets.yml
      + blog.yml
      + categories.yml
    + pages
      + about.md
    + posts
      + 2007
      + 2008
        + 9
          + my-article.md
    + templates
      + category.rhtml
      + category.rxml
      + comments.rhtml
      + feed.rxml
      + helpers.rb
      + index.rhtml
      + index.rxml
      + layout.rhtml
      + post.rhtml  


### Blog configuation

Inside `config/blog.yml` you will set the properties of your blog:

* title: the title of your blog, used inside templates

* description: used for RSS

* language: used for RSS

* author: used for RSS

* url: used for RSS

* blog_repository: path for rsync, used for `shinmun push` command

* base_path: if your blog should not be rendered to your site
  root, you can define a sub path here (like `blog`)


### Asset configuation

If you set the variables `javascripts_files` or `stylesheets_files`,
Shinmun will compress the javascripts to `all.js` and concatenate all
stylesheets to `all.css` automatically.

* images_path: used for templates helper

* javascripts_path: used for templates helper

* stylesheets_path: used for templates helper

* javascripts_files: a list of scripts to be compressed to `all.js`

* stylesheets_files: a list of stylesheets to be concatenated to `all.css`


### Categories

You have to list your categories in `config/categories.yml`. This will
look like:

    ---
    categories:
      - { name: Ruby }
      - { name: Javascript }

You may define arbitrary properties for each category, which then can
be accessed inside the templates. For example you could add a
description and use it inside the `templates/category.rhtml`.


### Layout

Layout and templates are rendered by *ERB*.  The layout is defined in
`templates/layout.rhtml`. The content will be provided in the variable
`@content`. A minimal but functional example:

    <html>
      <head>
        <title><%= @blog.title %></title>
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
`templates/helpers.rb` with a module named `Shinmun::Helpers`. This
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

      <!-- comment form -->
    </div>


### Commenting System

Commenting is only available in the rack handler. Comments are stored
as flat files and encoded as YAML objects. Each post has a
corresponding comment file located at `comments/<path to post>`. So
administration of comments is possible by editing the YAML file, you
can even version control your comments if you want.


### Static Output

To render your complete blog you may run `shinmun render` and the
output will be rendered to the `public` folder. Note that in this case
you will miss some dynamic features like the commenting system.

By issuing the `shinmun push` command your blog will be pushed to your
server using rsync. This works only, if you define the `repository`
variable inside `config/blog.yml`. It should contain something like
`user@myhost.com:/var/www/my-site/`.


### Realtime Rendering

Shinmun features a lightweight rack handler, which lets you run your
blog in almost any environment. In `shinmun-example` you will find a
rackup file called `config.ru`. To start the standalone server just
run:

    $ rackup

Browse to `http://localhost:9292` and you will see your blog served in
realtime. Just change any of your posts, templates or settings and you
will see the new output in your browser. Even the javascripts and
stylesheets will be packed at runtime if you configured it. Shinmun
caches all files, so that everything get served from memory.


### Phusion Passenger

Shinmun is already compatible with Phusion Passenger. Install Phusion
Passenger as described in my [blog post][2].

Now copy your blog folder to some folder like `/var/www/blog` and
create a sub directory `public`. Inside this directory you should link
your assets folders:

    # cd public
    # ln -s ../assets/images
    # ln -s ../assets/javascripts
    # ln -s ../assets/stylesheets

This is just to ensure that static files will be served by Apache.

Assuming that you are on a Debian or Ubuntu system, you can now create
a file named `/etc/apache2/sites-available/blog`:

    <VirtualHost *:80>
        ServerName myblog.com
        DocumentRoot /var/www/blog/public
    </VirtualHost>

Enable the new virtual host:

    $ a2ensite myapp

After restarting Apache your blog should run on Apache on your desired
domain:

    $ /etc/init.d/apache2 restart


### Download

Download or fork the package at my [github repository][1]


[1]: http://github.com/georgi/shinmun/tree/master
[2]: http://www.matthias-georgi.de/2008/9/quick-guide-for-passenger-on-ubuntu-hardy.html
[3]: http://github.com/georgi/shinmun-example/tree/master
