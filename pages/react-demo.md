---
title: React Components Demo
---
This page demonstrates embedding React components directly in Shinmun pages using TypeScript files.

## Hello World Component

A simple React component that renders a greeting:

    @@typescript-file[hello-react](public/apps/hello-react.tsx)

## Interactive Counter

A counter component using React hooks (useState):

    @@typescript-file[counter-react](public/apps/counter-react.tsx)

## Todo List Application

A full-featured todo list with add, complete, and delete functionality:

    @@typescript-file[todo-react](public/apps/todo-react.tsx)

## How It Works

React components can be embedded in two ways:

### 1. External File Reference

Reference a TypeScript/TSX file from your `public/apps` directory:

```markdown
    @@typescript-file[container-id](public/apps/component.tsx)
```

The file is compiled with esbuild, bundling imports and transforming JSX. React is loaded from a CDN via import maps.

### 2. Inline TypeScript

For simpler scripts, embed code directly:

```markdown
    @@typescript[my-app]

    const el = document.getElementById('my-app')!;
    el.innerHTML = '<p>Hello!</p>';
```

### File Structure

```
public/
  apps/
    hello-react.tsx    # Simple greeting component
    counter-react.tsx  # Interactive counter with hooks
    todo-react.tsx     # Todo list with CRUD operations
```

### Prerequisites

1. Install esbuild: `npm install esbuild`
2. Create your TSX files in `public/apps/`
3. Reference them in your markdown with `@@typescript-file`
