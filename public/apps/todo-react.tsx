// React Todo List component with full CRUD functionality
import React, { useState } from 'react';
import { createRoot } from 'react-dom/client';

interface Todo {
  id: number;
  text: string;
  completed: boolean;
}

function TodoApp() {
  const [todos, setTodos] = useState<Todo[]>([
    { id: 1, text: 'Learn React', completed: true },
    { id: 2, text: 'Build a Shinmun blog', completed: false },
    { id: 3, text: 'Embed React components', completed: false }
  ]);
  const [newTodo, setNewTodo] = useState('');

  const addTodo = () => {
    if (newTodo.trim()) {
      setTodos([
        ...todos,
        { id: Date.now(), text: newTodo.trim(), completed: false }
      ]);
      setNewTodo('');
    }
  };

  const toggleTodo = (id: number) => {
    setTodos(todos.map(todo =>
      todo.id === id ? { ...todo, completed: !todo.completed } : todo
    ));
  };

  const deleteTodo = (id: number) => {
    setTodos(todos.filter(todo => todo.id !== id));
  };

  const remaining = todos.filter(t => !t.completed).length;

  return (
    <div style={{ 
      padding: '1.5rem', 
      background: 'white',
      borderRadius: '8px',
      boxShadow: '0 2px 8px rgba(0,0,0,0.1)',
      fontFamily: 'system-ui, sans-serif',
      maxWidth: '400px'
    }}>
      <h3 style={{ margin: '0 0 1rem', color: '#333' }}>📝 Todo List</h3>
      
      <div style={{ display: 'flex', marginBottom: '1rem' }}>
        <input
          type="text"
          value={newTodo}
          onChange={(e) => setNewTodo(e.target.value)}
          onKeyPress={(e) => e.key === 'Enter' && addTodo()}
          placeholder="Add a new task..."
          style={{
            flex: 1,
            padding: '0.5rem',
            fontSize: '1rem',
            border: '1px solid #ddd',
            borderRadius: '4px 0 0 4px',
            outline: 'none'
          }}
        />
        <button
          onClick={addTodo}
          style={{
            padding: '0.5rem 1rem',
            background: '#4a90d9',
            color: 'white',
            border: 'none',
            borderRadius: '0 4px 4px 0',
            cursor: 'pointer'
          }}
        >
          Add
        </button>
      </div>

      <ul style={{ listStyle: 'none', padding: 0, margin: 0 }}>
        {todos.map(todo => (
          <li
            key={todo.id}
            style={{
              display: 'flex',
              alignItems: 'center',
              padding: '0.5rem',
              borderBottom: '1px solid #eee'
            }}
          >
            <input
              type="checkbox"
              checked={todo.completed}
              onChange={() => toggleTodo(todo.id)}
              style={{ marginRight: '0.5rem', cursor: 'pointer' }}
            />
            <span style={{
              flex: 1,
              textDecoration: todo.completed ? 'line-through' : 'none',
              color: todo.completed ? '#999' : '#333'
            }}>
              {todo.text}
            </span>
            <button
              onClick={() => deleteTodo(todo.id)}
              style={{
                padding: '0.25rem 0.5rem',
                background: '#ff4444',
                color: 'white',
                border: 'none',
                borderRadius: '4px',
                cursor: 'pointer',
                fontSize: '0.8rem'
              }}
            >
              ✕
            </button>
          </li>
        ))}
      </ul>

      <div style={{ 
        marginTop: '1rem', 
        fontSize: '0.9rem', 
        color: '#666',
        textAlign: 'center' 
      }}>
        {remaining} task{remaining !== 1 ? 's' : ''} remaining
      </div>
    </div>
  );
}

// Mount the component
const container = document.getElementById('todo-react');
if (container) {
  const root = createRoot(container);
  root.render(<TodoApp />);
}
