---
date: 2024-12-20
category: Ruby
tags: ruby, customization, templates
title: Extending Shinmun
---
Shinmun is designed for customization. Modify templates, add helpers, or define new routes.

## Templates

ERB templates in `templates/` control rendering. Key files:

- `layout.rhtml` - Main HTML wrapper
- `post.rhtml` - Single post view
- `index.rhtml` - Homepage listing
- `category.rhtml` - Category pages

Example `post.rhtml`:

    @@erb

    <article>
      <h1><%= @post.title %></h1>
      <time><%= human_date(@post.date) %></time>
      <%= @post.body_html %>
    </article>

## Custom Helpers

Add helpers in `lib/shinmun/helpers.rb`:

    @@ruby

    module Shinmun::Helpers
      def reading_time(post)
        words = post.body.split.size
        "#{(words / 200.0).ceil} min read"
      end
    end

Use in templates: `<%= reading_time(@post) %>`

## Custom Routes

Routes are defined in `lib/shinmun/routes.rb`. Add new endpoints:

    @@ruby

    Shinmun::Blog.map do
      get '/projects' do
        render 'projects.rhtml'
      end

      get '/api/posts.json' do
        content_type :json
        posts.map { |p| { title: p.title, date: p.date } }.to_json
      end
    end

## Configuration

`config.ru` sets blog properties:

    @@ruby

    blog.config = {
      title: "My Blog",
      author: "Name",
      categories: ["Ruby", "Web"],
      base_path: "/blog"
    }

Access in templates via `@blog.title`, `@blog.author`, etc.

## Static Export Hooks

Override `Exporter` methods for custom export behavior:

    @@ruby

    class Shinmun::Exporter
      def export
        super
        generate_sitemap
      end

      def generate_sitemap
        # Custom sitemap generation
      end
    end
