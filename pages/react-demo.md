---
title: React Components Demo
---
This page demonstrates Shinmun's powerful React integration, showcasing how to embed interactive React components directly in your Markdown pages using TypeScript.

## Why React?

React is a JavaScript library for building user interfaces. Combined with TypeScript, it provides:

- **Component-Based Architecture**: Build encapsulated components that manage their own state
- **Declarative Views**: Design simple views for each state, React efficiently updates the DOM
- **Type Safety**: TypeScript catches errors at compile time
- **Hooks**: Modern React patterns for state and effects

Shinmun automatically loads React from a CDN via import maps, so you can start building components immediately.

---

## Hello World Component

Let's start with a simple React component that renders a greeting. This demonstrates:

- Basic function components
- TypeScript interfaces for props
- Inline styling with `React.CSSProperties`

    @@typescript-file[hello-react](public/apps/hello-react.tsx)

**Source Code:**

```tsx
interface HelloProps {
  name: string;
}

function Hello({ name }: HelloProps) {
  return (
    <div style={{ padding: '1rem', background: 'linear-gradient(...)' }}>
      <h2>Hello, {name}! 👋</h2>
      <p>This is a React component embedded in Shinmun.</p>
    </div>
  );
}
```

---

## Interactive Counter

A counter component using React's `useState` hook. This demonstrates:

- State management with `useState`
- Event handlers with TypeScript types
- Conditional styling based on state

    @@typescript-file[counter-react](public/apps/counter-react.tsx)

**Key Concepts:**

```tsx
// useState with type inference
const [count, setCount] = useState(0);

// Update state with callback
setCount(c => c + 1);

// Conditional styling
color: count >= 0 ? '#2d7d46' : '#d93025'
```

---

## Theme Switcher

A more advanced component demonstrating multiple hooks and CSS-in-JS patterns:

- `useState` for current theme
- `useEffect` for transition animations
- TypeScript union types for theme options
- `Record<K, V>` for theme configurations

    @@typescript-file[theme-switcher](public/apps/theme-switcher.tsx)

**TypeScript Patterns Used:**

```tsx
// Union type for theme options
type Theme = 'light' | 'dark' | 'ocean' | 'forest';

// Record type for theme configurations
const themes: Record<Theme, ThemeConfig> = { ... };

// useEffect for side effects
useEffect(() => {
  setIsTransitioning(true);
  const timer = setTimeout(() => setIsTransitioning(false), 300);
  return () => clearTimeout(timer); // Cleanup!
}, [currentTheme]);
```

---

## Animated Data Chart

Interactive bar chart showcasing data visualization with React:

- Dynamic data generation
- Auto-update with `useEffect` intervals
- CSS transitions for smooth animations
- Multiple interactive controls

    @@typescript-file[animated-chart](public/apps/animated-chart.tsx)

**Animation Pattern:**

```tsx
// Smooth CSS transitions
const barStyle: React.CSSProperties = {
  height: `${(point.value / maxValue) * 160}px`,
  transition: 'height 0.5s cubic-bezier(0.4, 0, 0.2, 1)',
  transform: isAnimating ? 'scaleY(0.1)' : 'scaleY(1)',
  transformOrigin: 'bottom'
};
```

---

## Form with Validation

Comprehensive form demonstrating TypeScript's type safety with forms:

- Generic validator functions
- Controlled inputs with TypeScript event types
- `useCallback` for memoized handlers
- Real-time validation feedback

    @@typescript-file[form-validation](public/apps/form-validation.tsx)

**Validation Pattern with Generics:**

```tsx
// Generic validator type
type Validator<T> = (value: T, formData?: FormData) => string | undefined;

// Validators for each field
const validators: Record<keyof FormData, Validator<string>> = {
  email: (value) => {
    if (!value) return 'Email is required';
    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value)) 
      return 'Invalid email format';
    return undefined;
  },
  // ... more validators
};
```

---

## Real-Time Search Filter

Search and filter component showcasing `useMemo` for performance optimization:

- Complex filtering logic
- Sorting options
- Category filters
- Optimized re-renders with `useMemo`

    @@typescript-file[search-filter](public/apps/search-filter.tsx)

**useMemo for Optimized Filtering:**

```tsx
const filteredTechnologies = useMemo(() => {
  return technologies
    .filter(tech => {
      const matchesSearch = tech.name.toLowerCase()
        .includes(searchTerm.toLowerCase());
      const matchesCategory = selectedCategory === 'all' || 
        tech.category === selectedCategory;
      return matchesSearch && matchesCategory;
    })
    .sort((a, b) => {
      if (sortBy === 'name') return a.name.localeCompare(b.name);
      return b.stars - a.stars;
    });
}, [searchTerm, selectedCategory, sortBy]); // Dependencies
```

---

## Todo List Application

A full-featured todo list with CRUD operations:

- Add new todos
- Toggle completion status
- Delete todos
- Remaining count

    @@typescript-file[todo-react](public/apps/todo-react.tsx)

**State Management Pattern:**

```tsx
interface Todo {
  id: number;
  text: string;
  completed: boolean;
}

const [todos, setTodos] = useState<Todo[]>([...]);

// Toggle todo
const toggleTodo = (id: number) => {
  setTodos(todos.map(todo =>
    todo.id === id ? { ...todo, completed: !todo.completed } : todo
  ));
};
```

---

## How to Create Your Own Components

### Step 1: Create a TSX File

Create your component in `public/apps/`:

```tsx
// public/apps/my-widget.tsx
import React, { useState } from 'react';
import { createRoot } from 'react-dom/client';

function MyWidget() {
  const [value, setValue] = useState('');
  
  return (
    <div style={{ padding: '1rem', background: '#f5f5f5' }}>
      <input 
        value={value}
        onChange={(e) => setValue(e.target.value)}
        placeholder="Type something..."
      />
      <p>You typed: {value}</p>
    </div>
  );
}

// Mount to container
const container = document.getElementById('my-widget');
if (container) {
  const root = createRoot(container);
  root.render(<MyWidget />);
}
```

### Step 2: Reference in Markdown

```markdown
    @@typescript-file[my-widget](public/apps/my-widget.tsx)
```

### Step 3: That's It!

Shinmun handles:

- ✅ Compiling TypeScript/TSX
- ✅ Bundling dependencies
- ✅ Loading React from CDN
- ✅ Creating container elements

---

## React Hooks Cheat Sheet

### useState - State Management

```tsx
// Basic
const [count, setCount] = useState(0);

// With type
const [user, setUser] = useState<User | null>(null);

// Lazy initialization
const [data, setData] = useState(() => expensiveInit());
```

### useEffect - Side Effects

```tsx
// On mount/unmount
useEffect(() => {
  console.log('mounted');
  return () => console.log('unmounted');
}, []);

// On dependency change
useEffect(() => {
  fetchData(id);
}, [id]);
```

### useMemo - Memoization

```tsx
const computed = useMemo(() => {
  return expensiveCalculation(input);
}, [input]);
```

### useCallback - Stable Callbacks

```tsx
const handler = useCallback((e: Event) => {
  handleEvent(e, dependency);
}, [dependency]);
```

---

## File Structure

```
public/
  apps/
    hello-react.tsx      # Simple greeting
    counter-react.tsx    # Counter with hooks
    todo-react.tsx       # Full CRUD todo list
    theme-switcher.tsx   # Theme switching demo
    animated-chart.tsx   # Data visualization
    form-validation.tsx  # TypeScript form validation
    search-filter.tsx    # Real-time search
```

---

## Prerequisites

1. Install esbuild: `npm install esbuild`
2. Create your TSX files in `public/apps/`
3. Reference them in your markdown with `@@typescript-file`

React and ReactDOM are automatically loaded from a CDN—no additional dependencies needed!
