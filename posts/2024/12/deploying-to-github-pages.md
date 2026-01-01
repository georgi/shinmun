---
date: 2024-12-15
category: Ruby
tags: deployment, github, static-site
title: Deploying to GitHub Pages
---
Shinmun exports to static HTML for free hosting on GitHub Pages. Two deployment methods: manual export or GitHub Actions automation.

## Manual Export

    @@bash

    shinmun export docs
    git add docs && git commit -m "Export site"
    git push

In repository Settings → Pages, select **main** branch and **/docs** folder.

## GitHub Actions Automation

Create `.github/workflows/deploy.yml`:

    @@yaml

    name: Deploy
    on:
      push:
        branches: [main]
    permissions:
      contents: read
      pages: write
      id-token: write
    jobs:
      build:
        runs-on: ubuntu-latest
        steps:
          - uses: actions/checkout@v4
          - uses: ruby/setup-ruby@v1
            with:
              ruby-version: '3.2.0'
              bundler-cache: true
          - run: bundle exec shinmun export _site
          - uses: actions/upload-pages-artifact@v3
      deploy:
        needs: build
        runs-on: ubuntu-latest
        environment:
          name: github-pages
          url: ${{ steps.deployment.outputs.page_url }}
        steps:
          - uses: actions/deploy-pages@v4
            id: deployment

In Settings → Pages, set Source to **GitHub Actions**.

## Custom Domain

Add a `CNAME` file to `public/` with your domain. Configure DNS:
- **Apex domain**: A records to GitHub IPs
- **Subdomain**: CNAME to `username.github.io`

## Subpath Hosting

For project sites at `/repo-name/`, set `base_path` in `config.yml`:

    @@yaml

    base_path: /repo-name

Templates use `<%= base_path %>` for asset paths.
