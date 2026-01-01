// Simple React Hello World component
import React from 'react';
import { createRoot } from 'react-dom/client';

interface HelloProps {
  name: string;
}

function Hello({ name }: HelloProps) {
  return (
    <div style={{ 
      padding: '1rem', 
      background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
      borderRadius: '8px',
      color: 'white',
      fontFamily: 'system-ui, sans-serif'
    }}>
      <h2 style={{ margin: 0 }}>Hello, {name}! 👋</h2>
      <p style={{ margin: '0.5rem 0 0' }}>
        This is a React component embedded in a Shinmun page.
      </p>
    </div>
  );
}

// Mount the component
const container = document.getElementById('hello-react');
if (container) {
  const root = createRoot(container);
  root.render(<Hello name="Shinmun" />);
}
