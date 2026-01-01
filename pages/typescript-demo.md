---
title: TypeScript Mini Apps Demo
---
This page demonstrates embedding TypeScript mini apps directly in Shinmun pages.

## Simple TypeScript Example

The following TypeScript code runs as a mini app:

    @@typescript[greeting-app]

    const container = document.getElementById('greeting-app')!;
    const name: string = "Shinmun";
    container.innerHTML = `<p style="color: blue; font-weight: bold;">Hello from TypeScript, ${name}!</p>`;

## Counter App

A more interactive example with a counter:

    @@typescript[counter-app]

    interface CounterState { count: number; }
    const state: CounterState = { count: 0 };
    const container = document.getElementById('counter-app')!;
    function render(): void { container.innerHTML = `<div style="padding: 1em; border: 1px solid #ccc; border-radius: 4px; text-align: center;"><p>Count: <strong>${state.count}</strong></p><button onclick="window.increment()">+</button> <button onclick="window.decrement()">-</button></div>`; }
    (window as any).increment = (): void => { state.count++; render(); };
    (window as any).decrement = (): void => { state.count--; render(); };
    render();

## Clock Widget

A live updating clock widget:

    @@typescript[clock-app]

    const clockContainer = document.getElementById('clock-app')!;
    function updateClock(): void { const now: Date = new Date(); clockContainer.innerHTML = `<div style="font-family: monospace; font-size: 2em; padding: 0.5em; background: #333; color: #0f0; display: inline-block; border-radius: 4px;">${now.toLocaleTimeString()}</div>`; }
    updateClock();
    setInterval(updateClock, 1000);

## How It Works

TypeScript blocks are embedded using the `@@typescript` syntax, similar to code highlighting.

The TypeScript is compiled to JavaScript using esbuild and embedded as a `<script type="module">` block. If you specify a container ID (like `[container-id]`), a `<div>` with that ID is created before the script.

This makes it easy to create interactive mini apps, visualizations, and demos directly in your blog posts!
