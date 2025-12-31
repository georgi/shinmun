---
title: Deploying Shinmun to GitHub Pages
---
This guide explains how to deploy your Shinmun blog to GitHub Pages, allowing you to host your blog for free on GitHub's infrastructure.

## Overview

Shinmun includes a static site exporter that generates plain HTML files from your blog. These files can be hosted on GitHub Pages, which serves static content directly from your repository.

## Prerequisites

- A Shinmun blog set up and working locally
- Git installed on your system
- A GitHub account
- Ruby and the Shinmun gem installed

## Quick Start

1. Export your static site:

```bash
cd your-blog-directory
shinmun export docs
```

2. Commit and push the `docs` folder to GitHub

3. Enable GitHub Pages in your repository settings, selecting the `docs` folder as the source

## Detailed Setup Instructions

### Step 1: Export Your Static Site

The `shinmun export` command generates a static HTML version of your entire blog. By default, it exports to a `_site` directory, but for GitHub Pages, export to a `docs` folder:

```bash
shinmun export docs
```

This command will:
- Generate `index.html` for your homepage
- Create HTML files for all your posts and pages
- Generate category and archive pages
- Create the RSS feed (`index.rss`)
- Copy all static files from your `public` directory

### Step 2: Configure Your Repository

Initialize a Git repository if you haven't already:

```bash
git init
git add .
git commit -m "Initial commit with Shinmun blog"
```

Create a GitHub repository and push your code:

```bash
git remote add origin https://github.com/yourusername/your-blog.git
git branch -M main
git push -u origin main
```

### Step 3: Enable GitHub Pages

1. Go to your repository on GitHub
2. Click **Settings** → **Pages**
3. Under **Source**, select **Deploy from a branch**
4. Choose the **main** branch and select **/docs** folder
5. Click **Save**

Your blog will be available at `https://yourusername.github.io/your-blog/` within a few minutes.

## Using GitHub Actions for Automated Deployment

For a more automated workflow, you can use GitHub Actions to build and deploy your site whenever you push changes. This approach doesn't require committing the `docs` folder—instead, the site is built and deployed automatically on each push.

### Create the Workflow File

Create `.github/workflows/deploy.yml`:

```yaml
name: Deploy to GitHub Pages

on:
  push:
    branches: [main]
  workflow_dispatch:

permissions:
  contents: read
  pages: write
  id-token: write

concurrency:
  group: "pages"
  cancel-in-progress: false

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: '3.2.0'
          bundler-cache: true

      - name: Build site
        run: bundle exec shinmun export _site

      - name: Upload artifact
        uses: actions/upload-pages-artifact@v3

  deploy:
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    runs-on: ubuntu-latest
    needs: build
    steps:
      - name: Deploy to GitHub Pages
        id: deployment
        uses: actions/deploy-pages@v4
```

### Enable GitHub Actions Deployment

1. Go to your repository **Settings** → **Pages**
2. Under **Source**, select **GitHub Actions**
3. Push your changes to trigger the workflow

Now your site will automatically rebuild and deploy whenever you push to the main branch.

## Custom Domain Setup

To use a custom domain with your Shinmun blog:

1. Add a `CNAME` file to your `public` directory containing your domain:

```
yourdomain.com
```

2. Configure your domain's DNS:
   - For apex domains (yourdomain.com): Add A records pointing to GitHub's IP addresses
   - For subdomains (blog.yourdomain.com): Add a CNAME record pointing to `yourusername.github.io`

3. In repository **Settings** → **Pages**, enter your custom domain

4. Enable **Enforce HTTPS** for secure connections

## Tips and Best Practices

### Excluding the Export Directory from Git

If you prefer to only export during deployment (using GitHub Actions), add the export directory to `.gitignore`:

```
_site/
```

### Updating Your Blog

The typical workflow for updating your blog:

1. Create or edit posts:
   ```bash
   shinmun post "My New Post"
   # Edit the created file in posts/YYYY/M/my-new-post.md
   ```

2. Preview locally:
   ```bash
   rackup
   # Visit http://localhost:9292
   ```

3. Export and deploy:
   ```bash
   shinmun export docs
   git add .
   git commit -m "Add new post"
   git push
   ```

### Relative vs Absolute URLs

When hosting on a GitHub Pages project site (not a user/organization site), your blog will be at a subpath like `/your-repo/`. Make sure your templates use relative paths for assets:

```erb
<link rel="stylesheet" href="<%= base_path %>/styles.css">
```

## Troubleshooting

### 404 Errors on Posts

Ensure your posts have the `.html` extension when exported. GitHub Pages serves `index.html` automatically but requires explicit `.html` for other files.

### Styles Not Loading

Check that your CSS paths are correct. If your site is hosted at a subpath, you may need to configure `base_path` in your config.

### Build Failures in GitHub Actions

- Verify your `Gemfile` includes the `shinmun` gem
- Check Ruby version compatibility
- Review the Actions logs for specific error messages

## Example Repository Structure

After setup, your repository should look like this:

```
your-blog/
├── .github/
│   └── workflows/
│       └── deploy.yml
├── config.ru
├── config.yml
├── Gemfile
├── Gemfile.lock
├── pages/
│   └── about.md
├── posts/
│   └── 2024/
│       └── 1/
│           └── my-first-post.md
├── public/
│   ├── styles.css
│   └── CNAME
├── templates/
│   ├── index.rhtml
│   ├── layout.rhtml
│   ├── post.rhtml
│   └── ...
└── docs/          # Generated static site
    ├── index.html
    ├── index.rss
    └── ...
```

## Further Reading

- [GitHub Pages Documentation](https://docs.github.com/en/pages)
- [Configuring a custom domain for GitHub Pages](https://docs.github.com/en/pages/configuring-a-custom-domain-for-your-github-pages-site)
- [Shinmun GitHub Repository](https://github.com/georgi/shinmun)
