---
title: AI-Powered CLI Assistant
---
Shinmun includes an optional AI assistant that can help streamline your blog workflow. It generates draft content, suggests metadata, and creates SEO descriptions—all from the command line.

## Setup

The AI assistant requires an API key from either Anthropic (Claude) or OpenAI (GPT-4). Set one of these environment variables:

```bash
# For Anthropic Claude (recommended)
export ANTHROPIC_API_KEY="your-api-key"

# For OpenAI GPT-4
export OPENAI_API_KEY="your-api-key"
```

If both keys are set, the assistant uses Anthropic by default.

## Commands

### Generate a Draft Post

Use the `--ai` flag when creating a new post to generate a structured draft:

```bash
shinmun post "The future of Ruby" --ai
```

This creates a new post file with:
- **Body content**: 3-4 paragraphs of relevant, well-structured Markdown
- **Category**: Selected from your `config.yml` categories
- **Tags**: 3-5 relevant, comma-separated tags
- **Description**: An SEO-optimized meta description (150-160 characters)

Example output:
```
Generating draft with AI (anthropic)...
Created AI-generated post 'posts/2026/1/the-future-of-ruby.md'
  Category: Ruby
  Tags: ruby, programming, future, language-evolution
  Description: Explore Ruby's evolving ecosystem, from performance gains to new patterns shaping the language's future in web development.
```

### Enhance Existing Posts

Already have posts without proper metadata? Use `ai-enhance` to analyze content and fill in missing fields:

```bash
shinmun ai-enhance posts/2024/12/my-post.md
```

The command analyzes your post's content and suggests:
- A category (if not already set)
- Relevant tags (if not already set)
- An SEO description (if not already present)

**Important**: This command only updates empty fields. Existing metadata is preserved.

Example output:
```
Analyzing post with AI (anthropic)...
  Suggested category: Javascript
  Suggested tags: react, typescript, web development
  Generated description: Learn how to build type-safe React components with TypeScript for better developer experience and fewer runtime errors.
Updated 'posts/2024/12/my-post.md'
```

## How It Works

The AI assistant uses your configured LLM to:

1. **Understand context**: It reads your post title (for drafts) or body content (for enhancement)
2. **Match your blog**: It references your `config.yml` categories to suggest appropriate classifications
3. **Generate metadata**: It creates tags and descriptions optimized for search engines

All processing happens through direct API calls—no intermediate services or data storage.

## Post Format with AI Fields

After AI enhancement, your post's YAML header might look like:

```yaml
---
date: 2026-01-01
category: Ruby
tags: ruby, metaprogramming, dsl, patterns
title: Building Domain-Specific Languages in Ruby
description: A practical guide to creating expressive DSLs in Ruby using metaprogramming techniques for cleaner, more readable code.
---
```

The `description` field is used by templates for SEO meta tags and can improve your blog's search engine visibility.

## Configuration

The AI assistant reads your `config.yml` to understand your blog's structure:

```yaml
language: en
title: My Tech Blog
author: Your Name
categories:
  - Ruby
  - Javascript
  - Python
  - DevOps
description: A blog about software development
```

When generating content, the assistant will select from your defined categories rather than inventing new ones.

## Tips for Better Results

**For draft generation:**
- Use descriptive, specific titles: "Building a REST API with Sinatra" works better than "Web Development"
- The first paragraph of generated content serves as your post's summary in listings

**For content enhancement:**
- Write at least 2-3 paragraphs before running `ai-enhance`
- More content gives the AI better context for accurate categorization

**General:**
- Review and edit AI-generated content before publishing
- Adjust tags to match your blog's existing taxonomy
- Customize the description if it doesn't capture your post's unique angle

## Limitations

- Requires internet access for API calls
- Subject to API rate limits and pricing
- Generated content should be reviewed for accuracy
- Works best with technical and informational content

## Cost Considerations

Each AI operation makes one API call:
- Draft generation: ~500-1000 tokens input, ~500-800 tokens output
- Content enhancement: ~200-500 tokens input, ~100-200 tokens output

Monitor your API usage through your provider's dashboard.

## Troubleshooting

**"No AI API key configured"**
Ensure your environment variable is set and exported:
```bash
echo $ANTHROPIC_API_KEY  # Should show your key
```

**"API error: 401"**
Your API key is invalid or expired. Generate a new key from your provider's dashboard.

**"API error: 429"**
Rate limit exceeded. Wait a few minutes before retrying.

**JSON parsing errors**
Occasionally the AI response may be malformed. Simply retry the command.
