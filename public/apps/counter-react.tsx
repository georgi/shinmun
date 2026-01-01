// Interactive React Counter component with hooks
import React, { useState } from 'react';
import { createRoot } from 'react-dom/client';

function Counter() {
  const [count, setCount] = useState(0);

  const buttonStyle: React.CSSProperties = {
    padding: '0.5rem 1rem',
    fontSize: '1.2rem',
    margin: '0 0.25rem',
    borderRadius: '4px',
    border: 'none',
    cursor: 'pointer',
    background: '#4a90d9',
    color: 'white',
    transition: 'transform 0.1s'
  };

  return (
    <div style={{ 
      padding: '1.5rem', 
      background: '#f5f5f5',
      borderRadius: '8px',
      textAlign: 'center',
      fontFamily: 'system-ui, sans-serif'
    }}>
      <h3 style={{ margin: '0 0 1rem' }}>React Counter</h3>
      <div style={{ 
        fontSize: '3rem', 
        fontWeight: 'bold',
        color: count >= 0 ? '#2d7d46' : '#d93025',
        marginBottom: '1rem'
      }}>
        {count}
      </div>
      <div>
        <button 
          style={buttonStyle}
          onClick={() => setCount(c => c - 1)}
          onMouseOver={(e) => e.currentTarget.style.transform = 'scale(1.05)'}
          onMouseOut={(e) => e.currentTarget.style.transform = 'scale(1)'}
        >
          − Decrease
        </button>
        <button 
          style={{ ...buttonStyle, background: '#d93025' }}
          onClick={() => setCount(0)}
        >
          Reset
        </button>
        <button 
          style={buttonStyle}
          onClick={() => setCount(c => c + 1)}
          onMouseOver={(e) => e.currentTarget.style.transform = 'scale(1.05)'}
          onMouseOut={(e) => e.currentTarget.style.transform = 'scale(1)'}
        >
          + Increase
        </button>
      </div>
    </div>
  );
}

// Mount the component
const container = document.getElementById('counter-react');
if (container) {
  const root = createRoot(container);
  root.render(<Counter />);
}
