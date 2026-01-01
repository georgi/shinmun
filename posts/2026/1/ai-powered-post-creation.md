---
date: 2026-01-01
category: Ruby
tags: ai, cli, productivity, automation
title: AI-Powered Post Creation in Shinmun
description: Shinmun's new AI assistant generates draft content, suggests tags, and creates SEO descriptions from your command line.
---
Shinmun now includes an AI-powered CLI assistant that helps streamline the blog writing workflow. With a simple `--ai` flag, you can generate structured drafts, auto-populate metadata, and create SEO descriptions without leaving your terminal.

## The Problem

Writing blog posts involves more than just content. You need to:
- Choose an appropriate category
- Come up with relevant tags
- Write an SEO-friendly description
- Structure your post with a clear introduction

These tasks can slow down the creative process, especially when you want to quickly capture an idea.

## The Solution

Shinmun's AI assistant handles the boilerplate so you can focus on refining content:

    @@bash

    shinmun post "Building RESTful APIs with Sinatra" --ai

This single command creates a complete draft with:
- **Body content**: 3-4 paragraphs of well-structured Markdown
- **Category**: Automatically selected from your `config.yml`
- **Tags**: 3-5 relevant keywords
- **Description**: A 150-160 character SEO summary

## How It Works

The assistant uses either Anthropic's Claude or OpenAI's GPT-4 (depending on which API key you've configured) to:

1. Analyze your post title
2. Generate relevant, structured content
3. Match your blog's categories
4. Suggest appropriate tags
5. Create search-optimized descriptions

All processing happens through direct API calls—your content stays between you and the LLM provider.

## Enhancing Existing Posts

Already have posts without metadata? The `ai-enhance` command analyzes existing content:

    @@bash

    shinmun ai-enhance posts/2024/12/my-older-post.md

This fills in empty category, tags, and description fields while preserving any existing metadata.

## Setup

Add your API key as an environment variable:

    @@bash

    export ANTHROPIC_API_KEY="your-key"
    # or
    export OPENAI_API_KEY="your-key"

That's it. No additional dependencies or configuration required.

## Practical Considerations

The AI assistant is a drafting tool, not a replacement for your voice. Use it to:
- Quickly scaffold posts when inspiration strikes
- Add missing metadata to old content
- Generate starting points for technical topics

Always review and refine the generated content before publishing.

For complete documentation, see the [AI Assistant Guide](/ai-assistant-guide).
