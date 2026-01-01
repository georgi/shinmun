---
title: Deploying Shinmun to GitHub Pages
---
This guide explains how to deploy your Shinmun blog to GitHub Pages, allowing you to host your blog for free on GitHub's infrastructure. It also covers Shinmun's powerful TypeScript and React integration features with interactive demos.

## Overview

Shinmun includes a static site exporter that generates plain HTML files from your blog. These files can be hosted on GitHub Pages, which serves static content directly from your repository.

One of Shinmun's most powerful features is its ability to embed **TypeScript mini apps** and **React components** directly in your Markdown pages. This makes it perfect for creating interactive documentation, tutorials, and technical blogs.

## Prerequisites

- A Shinmun blog set up and working locally
- Git installed on your system
- A GitHub account
- Ruby and the Shinmun gem installed
- **For TypeScript/React features:** Node.js and npm installed

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

---

# TypeScript and React Features

Shinmun's most powerful feature is its seamless integration of TypeScript and React components directly into your Markdown pages. This enables you to create interactive tutorials, live code demos, and dynamic content without leaving your blog workflow.

## Setting Up TypeScript Support

Before using TypeScript features, install esbuild in your blog directory:

```bash
npm install esbuild
```

This allows Shinmun to compile TypeScript code on-the-fly during the build process.

## Inline TypeScript Mini Apps

The simplest way to add interactivity is with inline TypeScript blocks. Use the `@@typescript` syntax to embed code that runs directly in the browser.

### Basic Syntax

    @@typescript[container-id]

    // Your TypeScript code here
    const element = document.getElementById('container-id')!;
    element.innerHTML = '<p>Hello from TypeScript!</p>';

The `[container-id]` creates a `<div>` with that ID where your app can render.

### Example: Live Greeting

Here's a simple TypeScript app that displays a greeting:

    @@typescript[greeting-demo]

    interface User {
      name: string;
      role: 'admin' | 'user' | 'guest';
    }

    const user: User = { name: 'Developer', role: 'admin' };
    const container = document.getElementById('greeting-demo')!;
    
    const roleEmoji: Record<User['role'], string> = {
      admin: '👑',
      user: '👤',
      guest: '👋'
    };
    
    container.innerHTML = `
      <div style="padding: 1rem; background: #f0f9ff; border-radius: 8px; border-left: 4px solid #0284c7;">
        <p style="margin: 0; font-size: 1.1rem;">
          ${roleEmoji[user.role]} Welcome, <strong>${user.name}</strong>!
        </p>
        <p style="margin: 0.5rem 0 0; color: #64748b; font-size: 0.9rem;">
          You're logged in as: <code>${user.role}</code>
        </p>
      </div>
    `;

### Example: Interactive Counter with State

    @@typescript[counter-demo]

    interface State {
      count: number;
      history: number[];
    }

    const state: State = { count: 0, history: [] };
    const container = document.getElementById('counter-demo')!;

    function render(): void {
      container.innerHTML = `
        <div style="padding: 1.5rem; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); border-radius: 12px; color: white; text-align: center;">
          <div style="font-size: 3rem; font-weight: bold; margin-bottom: 1rem;">${state.count}</div>
          <div style="margin-bottom: 1rem;">
            <button onclick="window.decrement()" style="padding: 0.5rem 1.5rem; margin: 0.25rem; font-size: 1.2rem; cursor: pointer; border: none; border-radius: 6px; background: rgba(255,255,255,0.2); color: white;">−</button>
            <button onclick="window.reset()" style="padding: 0.5rem 1.5rem; margin: 0.25rem; font-size: 1.2rem; cursor: pointer; border: none; border-radius: 6px; background: rgba(255,255,255,0.2); color: white;">↺</button>
            <button onclick="window.increment()" style="padding: 0.5rem 1.5rem; margin: 0.25rem; font-size: 1.2rem; cursor: pointer; border: none; border-radius: 6px; background: rgba(255,255,255,0.2); color: white;">+</button>
          </div>
          <div style="font-size: 0.8rem; opacity: 0.8;">History: [${state.history.slice(-5).join(', ')}]</div>
        </div>
      `;
    }

    (window as any).increment = (): void => { state.history.push(state.count); state.count++; render(); };
    (window as any).decrement = (): void => { state.history.push(state.count); state.count--; render(); };
    (window as any).reset = (): void => { state.history.push(state.count); state.count = 0; render(); };
    render();

### Example: Real-Time Clock

    @@typescript[clock-demo]

    const clockContainer = document.getElementById('clock-demo')!;

    function updateClock(): void {
      const now = new Date();
      const hours = now.getHours().toString().padStart(2, '0');
      const minutes = now.getMinutes().toString().padStart(2, '0');
      const seconds = now.getSeconds().toString().padStart(2, '0');
      
      clockContainer.innerHTML = `
        <div style="font-family: 'SF Mono', monospace; background: #1a1a2e; padding: 1.5rem; border-radius: 12px; text-align: center; box-shadow: 0 4px 20px rgba(0,0,0,0.3);">
          <div style="font-size: 3rem; color: #00ff88; text-shadow: 0 0 20px #00ff8844;">
            ${hours}:${minutes}:<span style="color: #ff6b6b;">${seconds}</span>
          </div>
          <div style="color: #64748b; font-size: 0.9rem; margin-top: 0.5rem;">
            ${now.toLocaleDateString('en-US', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' })}
          </div>
        </div>
      `;
    }

    updateClock();
    setInterval(updateClock, 1000);

## TypeScript Type Features Showcase

TypeScript brings powerful type safety to your mini apps. Here are some patterns you can use:

### Interfaces and Types

```typescript
// Define clear interfaces for your data
interface BlogPost {
  id: number;
  title: string;
  author: string;
  tags: string[];
  published: boolean;
  createdAt: Date;
}

// Use union types for controlled values
type Status = 'draft' | 'review' | 'published' | 'archived';

// Use generics for reusable components
type ApiResponse<T> = {
  data: T;
  error: string | null;
  loading: boolean;
};
```

### Type Guards

```typescript
// Type guards for runtime type checking
function isError(response: unknown): response is { error: string } {
  return typeof response === 'object' && response !== null && 'error' in response;
}
```

### Mapped and Conditional Types

```typescript
// Create types from other types
type ReadonlyPost = Readonly<BlogPost>;
type PartialPost = Partial<BlogPost>;
type PostKeys = keyof BlogPost;

// Pick specific properties
type PostSummary = Pick<BlogPost, 'id' | 'title' | 'author'>;
```

---

## React Components Integration

For more complex interactive components, Shinmun supports embedding React components from external TSX files. This is perfect for reusable UI elements, forms, and data visualizations.

### Setting Up React

React is automatically loaded from a CDN via import maps. No additional setup is required—just create your TSX files in the `public/apps/` directory.

### File Reference Syntax

```markdown
    @@typescript-file[container-id](public/apps/component-name.tsx)
```

This compiles the TSX file with bundling enabled and embeds the result.

### Demo: Theme Switcher

This component demonstrates `useState`, `useEffect`, CSS-in-JS patterns, and TypeScript interfaces:

    @@typescript-file[theme-switcher](public/apps/theme-switcher.tsx)

**Key Features:**
- **TypeScript Union Types** for theme names (`'light' | 'dark' | 'ocean' | 'forest'`)
- **`Record<K, V>`** type for theme configurations
- **`useState`** hook for theme state management
- **`useEffect`** hook for transition animations
- **CSS-in-JS** with `React.CSSProperties` type

### Demo: Animated Data Chart

Interactive bar chart with auto-update functionality:

    @@typescript-file[animated-chart](public/apps/animated-chart.tsx)

**Key Features:**
- **Interface definitions** for data structure
- **`useMemo`** for computed values
- **`useEffect`** for interval-based updates with cleanup
- **CSS transitions** for smooth animations
- **Conditional rendering** based on state

### Demo: Form with TypeScript Validation

A comprehensive form demonstrating TypeScript generics and validation patterns:

    @@typescript-file[form-validation](public/apps/form-validation.tsx)

**Key Features:**
- **Generic validator functions** (`Validator<T>`)
- **`Record<K, V>`** for field configurations
- **Controlled form inputs** with TypeScript event types
- **`useCallback`** for memoized validation
- **Type-safe form state management**

### Demo: Real-Time Search Filter

Search and filter component showcasing `useMemo` and optimized rendering:

    @@typescript-file[search-filter](public/apps/search-filter.tsx)

**Key Features:**
- **Complex interfaces** with union type properties
- **`useMemo`** for optimized filtering/sorting
- **Array methods** with TypeScript generics
- **Type-safe event handlers**
- **Conditional styling** based on state

---

## React Hooks Reference

Here's a quick reference for React hooks commonly used in Shinmun components:

### useState

```tsx
// Basic state
const [count, setCount] = useState(0);

// State with type inference
const [user, setUser] = useState<User | null>(null);

// State with initial function
const [items, setItems] = useState(() => loadFromStorage());
```

### useEffect

```tsx
// Run on mount
useEffect(() => {
  console.log('Component mounted');
  return () => console.log('Component unmounted');
}, []);

// Run when dependency changes
useEffect(() => {
  document.title = `Count: ${count}`;
}, [count]);

// Interval with cleanup
useEffect(() => {
  const id = setInterval(tick, 1000);
  return () => clearInterval(id);
}, []);
```

### useMemo

```tsx
// Expensive computation cached
const sortedItems = useMemo(() => {
  return items.sort((a, b) => a.name.localeCompare(b.name));
}, [items]);

// Filtered list
const visibleItems = useMemo(() => {
  return items.filter(item => item.category === selectedCategory);
}, [items, selectedCategory]);
```

### useCallback

```tsx
// Memoized callback for child components
const handleClick = useCallback((id: number) => {
  setSelectedId(id);
}, []);

// Callback with dependencies
const handleSubmit = useCallback(() => {
  submitForm(formData);
}, [formData]);
```

---

## Creating Your Own Components

### Step 1: Create the TSX File

Create a new file in `public/apps/`:

```tsx
// public/apps/my-component.tsx
import React, { useState } from 'react';
import { createRoot } from 'react-dom/client';

interface Props {
  initialValue?: number;
}

function MyComponent({ initialValue = 0 }: Props) {
  const [value, setValue] = useState(initialValue);
  
  return (
    <div style={{ padding: '1rem', background: '#f5f5f5', borderRadius: '8px' }}>
      <p>Value: {value}</p>
      <button onClick={() => setValue(v => v + 1)}>Increment</button>
    </div>
  );
}

// Mount to container
const container = document.getElementById('my-component');
if (container) {
  const root = createRoot(container);
  root.render(<MyComponent />);
}
```

### Step 2: Reference in Markdown

In your page or post:

```markdown
    @@typescript-file[my-component](public/apps/my-component.tsx)
```

### Step 3: Preview and Deploy

```bash
# Preview locally
rackup

# Export for GitHub Pages
shinmun export docs
```

---

## Best Practices for TypeScript/React in Shinmun

### 1. Keep Components Focused

Each component file should do one thing well. Split complex UIs into smaller, reusable pieces.

### 2. Use TypeScript Strictly

Enable strict mode benefits by defining clear interfaces:

```typescript
// Good: Clear interface
interface User {
  id: number;
  name: string;
  email: string;
}

// Avoid: Loose typing
const user: any = { ... };
```

### 3. Handle Loading and Error States

```tsx
function DataComponent() {
  const [data, setData] = useState<Data | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);

  if (loading) return <div>Loading...</div>;
  if (error) return <div>Error: {error}</div>;
  if (!data) return <div>No data</div>;
  
  return <div>{/* Render data */}</div>;
}
```

### 4. Use CSS-in-JS Consistently

```tsx
// Define styles as constants for reusability
const styles = {
  container: {
    padding: '1rem',
    borderRadius: '8px',
  } as React.CSSProperties,
  button: {
    background: '#4a90d9',
    color: 'white',
    border: 'none',
    padding: '0.5rem 1rem',
    borderRadius: '4px',
    cursor: 'pointer',
  } as React.CSSProperties,
};
```

### 5. Clean Up Effects

Always return cleanup functions from effects that create subscriptions or timers:

```tsx
useEffect(() => {
  const subscription = eventSource.subscribe(handler);
  return () => subscription.unsubscribe();
}, []);
```

---

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
