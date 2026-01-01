---
title: TypeScript Mini Apps Demo
---
This page showcases Shinmun's powerful TypeScript integration, demonstrating how to embed interactive mini apps directly in your Markdown pages with full type safety.

## What is TypeScript?

TypeScript is a strongly typed programming language that builds on JavaScript. It adds optional static typing, classes, and interfaces, making it easier to build and maintain large-scale applications.

With Shinmun, you can write TypeScript code directly in your Markdown files, and it gets compiled to JavaScript using esbuild—one of the fastest JavaScript bundlers available.

---

## Simple TypeScript Example

The following TypeScript code demonstrates basic type annotations and DOM manipulation:

    @@typescript[greeting-app]

    const container = document.getElementById('greeting-app')!;
    const name: string = "Shinmun";
    container.innerHTML = `<p style="color: blue; font-weight: bold;">Hello from TypeScript, ${name}!</p>`;

---

## Interface Demo

TypeScript interfaces define the shape of objects, providing compile-time type checking:

    @@typescript[interface-demo]

    interface Person {
      name: string;
      age: number;
      occupation: string;
      skills: string[];
    }

    const developer: Person = {
      name: "Alex Chen",
      age: 28,
      occupation: "Full Stack Developer",
      skills: ["TypeScript", "React", "Node.js", "PostgreSQL"]
    };

    const container = document.getElementById('interface-demo')!;
    container.innerHTML = `
      <div style="padding: 1.5rem; background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%); border-radius: 12px; font-family: system-ui, sans-serif;">
        <div style="display: flex; align-items: center; margin-bottom: 1rem;">
          <div style="width: 60px; height: 60px; background: #4a90d9; border-radius: 50%; display: flex; align-items: center; justify-content: center; color: white; font-size: 1.5rem; font-weight: bold;">
            ${developer.name[0]}
          </div>
          <div style="margin-left: 1rem;">
            <h3 style="margin: 0; color: #333;">${developer.name}</h3>
            <p style="margin: 0.25rem 0 0; color: #666;">${developer.occupation}, ${developer.age} years old</p>
          </div>
        </div>
        <div style="display: flex; flex-wrap: wrap; gap: 0.5rem;">
          ${developer.skills.map(skill => `
            <span style="padding: 0.25rem 0.75rem; background: white; border-radius: 20px; font-size: 0.85rem; color: #4a90d9; box-shadow: 0 2px 4px rgba(0,0,0,0.1);">
              ${skill}
            </span>
          `).join('')}
        </div>
      </div>
    `;

---

## Union Types and Type Guards

TypeScript union types allow a value to be one of several types:

    @@typescript[union-demo]

    type Status = 'pending' | 'processing' | 'completed' | 'failed';

    interface Task {
      id: number;
      title: string;
      status: Status;
    }

    const tasks: Task[] = [
      { id: 1, title: 'Write documentation', status: 'completed' },
      { id: 2, title: 'Review pull request', status: 'processing' },
      { id: 3, title: 'Deploy to production', status: 'pending' },
      { id: 4, title: 'Fix critical bug', status: 'failed' }
    ];

    const statusColors: Record<Status, { bg: string; text: string; icon: string }> = {
      pending: { bg: '#fef3c7', text: '#92400e', icon: '⏳' },
      processing: { bg: '#dbeafe', text: '#1e40af', icon: '🔄' },
      completed: { bg: '#d1fae5', text: '#065f46', icon: '✅' },
      failed: { bg: '#fee2e2', text: '#991b1b', icon: '❌' }
    };

    const container = document.getElementById('union-demo')!;
    container.innerHTML = `
      <div style="font-family: system-ui, sans-serif;">
        <h4 style="margin: 0 0 1rem; color: #333;">Task Status Board</h4>
        ${tasks.map(task => {
          const style = statusColors[task.status];
          return `
            <div style="padding: 0.75rem 1rem; margin-bottom: 0.5rem; background: ${style.bg}; border-radius: 8px; display: flex; justify-content: space-between; align-items: center;">
              <span style="color: ${style.text};">${task.title}</span>
              <span style="padding: 0.25rem 0.5rem; background: white; border-radius: 4px; font-size: 0.8rem; color: ${style.text};">
                ${style.icon} ${task.status}
              </span>
            </div>
          `;
        }).join('')}
      </div>
    `;

---

## Interactive Counter App

A more complex example with state management and event handling:

    @@typescript[counter-app]

    interface CounterState { count: number; }
    const state: CounterState = { count: 0 };
    const container = document.getElementById('counter-app')!;
    function render(): void { container.innerHTML = `<div style="padding: 1em; border: 1px solid #ccc; border-radius: 4px; text-align: center;"><p>Count: <strong>${state.count}</strong></p><button onclick="window.increment()">+</button> <button onclick="window.decrement()">-</button></div>`; }
    (window as any).increment = (): void => { state.count++; render(); };
    (window as any).decrement = (): void => { state.count--; render(); };
    render();

---

## Generics Demo

TypeScript generics allow you to create reusable components:

    @@typescript[generics-demo]

    // Generic function that works with any array type
    function getFirst<T>(items: T[]): T | undefined {
      return items[0];
    }

    function getLast<T>(items: T[]): T | undefined {
      return items[items.length - 1];
    }

    // Generic interface for API responses
    interface ApiResponse<T> {
      data: T;
      status: number;
      message: string;
    }

    // Using generics with different types
    const numbers: number[] = [1, 2, 3, 4, 5];
    const names: string[] = ["Alice", "Bob", "Charlie"];
    
    const firstNum = getFirst(numbers);
    const lastName = getLast(names);

    const userResponse: ApiResponse<{ name: string; id: number }> = {
      data: { name: "John", id: 123 },
      status: 200,
      message: "Success"
    };

    const container = document.getElementById('generics-demo')!;
    container.innerHTML = `
      <div style="padding: 1.5rem; background: #1e1e1e; border-radius: 12px; font-family: 'SF Mono', monospace; color: #d4d4d4;">
        <div style="margin-bottom: 1rem;">
          <span style="color: #569cd6;">const</span> <span style="color: #9cdcfe;">firstNum</span> = <span style="color: #ce9178;">getFirst</span>([1, 2, 3, 4, 5])
          <br/>→ <span style="color: #4ec9b0;">${firstNum}</span>
        </div>
        <div style="margin-bottom: 1rem;">
          <span style="color: #569cd6;">const</span> <span style="color: #9cdcfe;">lastName</span> = <span style="color: #ce9178;">getLast</span>(["Alice", "Bob", "Charlie"])
          <br/>→ <span style="color: #ce9178;">"${lastName}"</span>
        </div>
        <div>
          <span style="color: #569cd6;">const</span> <span style="color: #9cdcfe;">response</span>: <span style="color: #4ec9b0;">ApiResponse</span>&lt;User&gt;
          <br/>→ <span style="color: #9cdcfe;">{ data: { name: "${userResponse.data.name}", id: ${userResponse.data.id} }, status: ${userResponse.status} }</span>
        </div>
      </div>
    `;

---

## Clock Widget

A live updating clock demonstrating TypeScript with intervals:

    @@typescript[clock-app]

    const clockContainer = document.getElementById('clock-app')!;
    function updateClock(): void { const now: Date = new Date(); clockContainer.innerHTML = `<div style="font-family: monospace; font-size: 2em; padding: 0.5em; background: #333; color: #0f0; display: inline-block; border-radius: 4px;">${now.toLocaleTimeString()}</div>`; }
    updateClock();
    setInterval(updateClock, 1000);

---

## Async/Await Example

TypeScript handles asynchronous code elegantly:

    @@typescript[async-demo]

    interface Quote {
      text: string;
      author: string;
    }

    const quotes: Quote[] = [
      { text: "The only way to do great work is to love what you do.", author: "Steve Jobs" },
      { text: "Innovation distinguishes between a leader and a follower.", author: "Steve Jobs" },
      { text: "Stay hungry, stay foolish.", author: "Steve Jobs" },
      { text: "Code is like humor. When you have to explain it, it's bad.", author: "Cory House" },
      { text: "First, solve the problem. Then, write the code.", author: "John Johnson" },
      { text: "Experience is the name everyone gives to their mistakes.", author: "Oscar Wilde" }
    ];

    let currentIndex = 0;
    const container = document.getElementById('async-demo')!;

    async function simulateFetch(): Promise<Quote> {
      // Simulate network delay
      await new Promise(resolve => setTimeout(resolve, 500));
      const quote = quotes[currentIndex];
      currentIndex = (currentIndex + 1) % quotes.length;
      return quote;
    }

    async function loadQuote(): Promise<void> {
      container.innerHTML = `
        <div style="padding: 2rem; background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%); border-radius: 12px; text-align: center; min-height: 120px;">
          <div style="color: white; font-size: 1rem;">Loading...</div>
        </div>
      `;

      const quote = await simulateFetch();
      
      container.innerHTML = `
        <div style="padding: 2rem; background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%); border-radius: 12px; text-align: center; font-family: system-ui, sans-serif;">
          <p style="color: white; font-size: 1.2rem; font-style: italic; margin: 0 0 1rem;">"${quote.text}"</p>
          <p style="color: rgba(255,255,255,0.8); margin: 0 0 1rem;">— ${quote.author}</p>
          <button onclick="window.loadNewQuote()" style="padding: 0.5rem 1.5rem; background: rgba(255,255,255,0.2); border: 2px solid white; border-radius: 20px; color: white; cursor: pointer; font-size: 0.9rem;">
            🔄 New Quote
          </button>
        </div>
      `;
    }

    (window as any).loadNewQuote = loadQuote;
    loadQuote();

---

## How It Works

TypeScript blocks are embedded using the `@@typescript` syntax, similar to code highlighting.

The TypeScript is compiled to JavaScript using esbuild and embedded as a `<script type="module">` block. If you specify a container ID (like `[container-id]`), a `<div>` with that ID is created before the script.

### Syntax Reference

**Simple inline TypeScript (no container):**

```markdown
    @@typescript

    console.log('Hello, TypeScript!');
```

**TypeScript with container element:**

```markdown
    @@typescript[my-container]

    const el = document.getElementById('my-container')!;
    el.innerHTML = '<p>Interactive content</p>';
```

**External TypeScript file:**

```markdown
    @@typescript-file[container-id](path/to/file.tsx)
```

### TypeScript Features Available

- ✅ Type annotations
- ✅ Interfaces and types
- ✅ Generics
- ✅ Union and intersection types
- ✅ Type guards
- ✅ Async/await
- ✅ Classes and inheritance
- ✅ ES modules (for external files)
- ✅ JSX/TSX (for React components)
