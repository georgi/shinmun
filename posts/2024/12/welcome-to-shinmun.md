---
date: 2024-12-01
category: Ruby
tags: introduction, getting-started
title: Shinmun Blog Engine
---
Shinmun is a file-based blog engine built on Ruby and Rack. Posts are Markdown files with YAML frontmatter, tracked in Git, served dynamically or exported as static HTML.

## Installation

    @@bash

    gem install shinmun
    shinmun init myblog
    cd myblog && rackup

Visit `http://localhost:9292` to see your blog.

## Creating Posts

    @@bash

    shinmun post 'Post Title'

Creates `posts/YYYY/M/post-title.md` with this structure:

    @@yaml

    ---
    date: 2024-12-01
    category: Ruby
    tags: tag1, tag2
    title: Post Title
    ---
    Your markdown content here.

## Directory Layout

    posts/          # Blog posts organized by year/month
    pages/          # Static pages (about, etc.)
    templates/      # ERB templates for rendering
    public/         # CSS, images, static assets
    config.ru       # Rack configuration

## Code Highlighting

Use `@@language` followed by a blank line and indented code:

    @@ruby

    def greet(name)
      "Hello, #{name}!"
    end

Rouge handles syntax highlighting for Ruby, JavaScript, Python, and 100+ languages.
