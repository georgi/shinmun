Shinmun - a file based blog engine
=================================

Shinmun is a small file based blog engine. Write posts in your favorite
editor, track them with git and deploy to Heroku. Small, fast and simple.

### Features

* Posts are text files formatted with [Markdown][8], [Textile][9] or [HTML][10]
* Deploy via Github Pages
* Index, category and archive listings
* RSS feeds
* Syntax highlighting provided by [Rouge][4]
* **TypeScript mini apps** - embed interactive TypeScript code in your pages
* **AI-powered CLI** - generate drafts, auto-tag posts, and create SEO descriptions
* **Reading time** - automatic reading time estimates for posts
* **Related posts** - find similar posts by tags and categories
* **Table of contents** - auto-generated TOC from headings
* **SEO meta tags** - Open Graph and Twitter Cards support
* **Sitemap** - automatic sitemap.xml generation
* **Search** - JSON search index for client-side search
* **Draft posts** - keep drafts unpublished until ready
* **Pagination** - helpers for paginating post listings


### Quickstart

Install the gems:

    $ gem install shinmun

Create a sample blog:

    $ shinmun init myblog

This will create a directory with all necessary files. Now start the
web server:

    $ cd myblog
    $ rackup

Browse to the following url:

    http://localhost:9292

Voilà, your first blog is up and running!


### Writing Posts

Posts can be created by using the `shinmun` command inside your blog
folder:

    shinmun post 'The title of the post'

Shinmun will then create a post file in the right place, for example
in `posts/2008/9/the-title-of-the-post.md`.

#### AI-Generated Drafts

Add the `--ai` flag to generate a complete draft with content, tags, and metadata:

    shinmun post 'The future of Ruby' --ai

This requires an API key from Anthropic or OpenAI:

    export ANTHROPIC_API_KEY="your-key"  # or OPENAI_API_KEY

The AI assistant will:
- Write 3-4 structured paragraphs based on your title
- Select a category from your `config.yml`
- Suggest relevant tags
- Generate an SEO description

See the [AI Assistant Guide](pages/ai-assistant-guide.md) for details.


### Post Format

Each blog post is just a text file with a YAML header and a body. The
YAML header is surrounded with 2 lines of 3 dashes.

The YAML header has following attributes:

* `title`: mandatory
* `date`: posts need one, pages not
* `category`: a post belongs to one category
* `tags`: a comma separated list of tags
* `description`: SEO meta description (optional, can be AI-generated)
* `draft`: set to `true` to keep the post unpublished

Example post:

    --- 
    date: 2008-09-05
    category: Ruby
    tags: kramdown, markdown
    title: Kramdown, a Markdown library
    description: A practical guide to using Kramdown for Markdown processing in Ruby applications.
    draft: false
    ---
    This is the summary, which is by definition the first paragraph of the
    article. The summary shows up in category listings or the index listing.

#### Enhancing Existing Posts

Use `ai-enhance` to add metadata to posts you've already written:

    shinmun ai-enhance posts/2024/12/my-post.md

This analyzes your content and fills in empty category, tags, and description fields.


### Syntax highlighting

Thanks to the fantastic highlighting library [Rouge][4], highlighted
code blocks can be embedded easily in Markdown. Rouge supports a wide
variety of languages including Ruby, Python, JavaScript, C, Java,
HTML, CSS, JSON, YAML, and many more.

To activate Rouge for a code block, you have to declare the language
in lower case:

    @@ruby

    def method_missing(id, *args, &block)
      puts "#{id} was called with #{args.inspect}"
    end             

**Note that the declaration MUST be followed by a blank line!**


### TypeScript Mini Apps

Shinmun supports embedding TypeScript mini apps directly in your pages.
TypeScript code is compiled to JavaScript using [esbuild][12] and embedded
as a `<script type="module">` block.

**Prerequisites:** You need to have Node.js and npm installed, then run
`npm install esbuild` in your blog directory.

#### Inline TypeScript

To embed TypeScript, use `@@typescript` followed by a blank line and
indented code:

    @@typescript

    const greeting: string = "Hello, World!";
    document.body.innerHTML = `<h1>${greeting}</h1>`;

For mini apps that need a container element, specify a container ID:

    @@typescript[my-app]

    const container = document.getElementById('my-app')!;
    container.innerHTML = '<p>Interactive content here!</p>';

This creates a `<div id="my-app"></div>` before the script.

#### External TypeScript Files

For larger components (like React), reference external TypeScript/TSX files:

    @@typescript-file[my-component](public/apps/my-component.tsx)

This reads the file, compiles it with bundling enabled, and embeds the result.
React is automatically loaded from a CDN via import maps.

**Example React component** (save as `public/apps/counter.tsx`):

```tsx
import React, { useState } from 'react';
import { createRoot } from 'react-dom/client';

function Counter() {
  const [count, setCount] = useState(0);
  return (
    <button onClick={() => setCount(c => c + 1)}>
      Count: {count}
    </button>
  );
}

const root = createRoot(document.getElementById('my-component')!);
root.render(<Counter />);
```

Then in your markdown:

    @@typescript-file[my-component](public/apps/counter.tsx)

**Note:** Each TypeScript block must end with a blank line before the
next content paragraph.


### Directory layout

    + config.ru
    + pages
      + about.md
    + posts
      + 2007
      + 2008
        + 9
          + my-article.md
    + public
      + styles.css
      + apps              # TypeScript/React components
        + counter.tsx
        + todo.tsx
    + templates
      + 404.rhtml
      + archive.rhtml
      + category.rhtml
      + index.rhtml
      + index.rxml
      + layout.rhtml
      + page.rhtml
      + post.rhtml  

### Blog configuation

In `config.ru` you can set the properties of your blog:

    blog.config = {
      :language => 'en',
      :title => "Blog Title",
      :author => "The Author",
      :categories => ["Ruby", "Javascript"],
      :description => "Blog description"
    }

Alternatively, use `config.yml` for configuration:

    language: en
    title: Blog Title
    author: The Author
    categories:
      - Ruby
      - Javascript
    description: Blog description
    base_path: /myblog
    site_url: https://yoursite.com  # Used for sitemap and SEO meta tags
    
    # Custom variables for templates (injected as window.* in JavaScript)
    variables:
      MY_API_KEY: "your-api-key"
      FEATURE_FLAG: "enabled"


### Templates

Layout and templates are rendered by *ERB*.  The layout is defined in
`templates/layout.rhtml`. The content will be provided in the variable
`@content`. A minimal example:

    <html>
      <head>
        <title><%= @blog.title %></title>
        <%= stylesheet_link_tag 'style' %>
        <%= variables_script_tag %>
      </head>
      <body>
         <%= @content %>
      </body>
     </html>

The `<%= variables_script_tag %>` helper injects any variables defined in
`config.yml` as JavaScript `window.*` variables, making them available to
TypeScript mini apps.

The attributes of a post are accessible via the @post variable:

    <div class="article">
     
      <h1><%= @post.title %></h1>
     
      <div class="date">
        <%= human_date @post.date %>
      </div>
     
      <%= @post.body_html %>

      ...      

    </div>

#### Template Helpers

Shinmun provides several helpers for use in your templates:

**Reading time:**
    <%= reading_time_tag @post %>  <!-- outputs "5 min read" -->

**Table of contents:**
    <%= @post.toc_html %>  <!-- generates a nested list of headings -->

**Related posts:**
    <%= related_posts_html @post, limit: 3 %>  <!-- shows similar posts -->

**SEO meta tags** (add to layout `<head>`):
    <%= seo_meta_tags(post: @post) %>  <!-- generates Open Graph, Twitter Cards, canonical URL -->

**Pagination:**
    <% pagination = paginate(@blog.published_posts, per_page: 10, current_page: params[:page] || 1) %>
    <% for post in pagination[:items] %>
      <%= post_link post %>
    <% end %>
    <%= pagination_html(pagination, base_url: '/') %>


### Deployment on GitHub Pages

Shinmun can generate a static site that you can host on GitHub Pages for free.

Export your blog to static files:

    $ shinmun export docs

This generates:
- HTML files for all posts, pages, categories, and archives
- `sitemap.xml` for search engines
- `search-index.json` for client-side search
- RSS feed at `index.rss`

Commit the `docs` folder and push to GitHub. Then enable GitHub Pages in your
repository settings, selecting the `docs` folder as the source.

For detailed instructions including GitHub Actions automation and custom domain
setup, see the [GitHub Pages Guide](pages/github-pages-guide.md).


### GitHub Project

Download or fork the package at my [github repository][1]


[1]: http://github.com/georgi/shinmun
[4]: https://github.com/rouge-ruby/rouge
[5]: http://www.modrails.com/
[6]: http://github.com/rack/rack
[8]: http://daringfireball.net/projects/markdown/
[9]: http://textile.thresholdstate.com/
[10]: http://en.wikipedia.org/wiki/Html
[11]: http://www.kernel.org/pub/software/scm/git/docs/git-push.html
[12]: https://esbuild.github.io/
