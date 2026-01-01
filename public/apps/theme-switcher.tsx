// Theme Switcher Demo - Showcases React hooks (useState, useEffect) and CSS-in-JS
import React, { useState, useEffect } from 'react';
import { createRoot } from 'react-dom/client';

type Theme = 'light' | 'dark' | 'ocean' | 'forest';

interface ThemeConfig {
  name: string;
  background: string;
  text: string;
  primary: string;
  accent: string;
  emoji: string;
}

const themes: Record<Theme, ThemeConfig> = {
  light: {
    name: 'Light',
    background: '#ffffff',
    text: '#333333',
    primary: '#4a90d9',
    accent: '#f0f4f8',
    emoji: '☀️'
  },
  dark: {
    name: 'Dark',
    background: '#1a1a2e',
    text: '#eaeaea',
    primary: '#e94560',
    accent: '#16213e',
    emoji: '🌙'
  },
  ocean: {
    name: 'Ocean',
    background: '#0a4d68',
    text: '#ffffff',
    primary: '#05bfdb',
    accent: '#088395',
    emoji: '🌊'
  },
  forest: {
    name: 'Forest',
    background: '#1a4d2e',
    text: '#f5f5dc',
    primary: '#4e9f3d',
    accent: '#2c5f2d',
    emoji: '🌲'
  }
};

function ThemeSwitcher() {
  const [currentTheme, setCurrentTheme] = useState<Theme>('light');
  const [isTransitioning, setIsTransitioning] = useState(false);

  const theme = themes[currentTheme];

  useEffect(() => {
    setIsTransitioning(true);
    const timer = setTimeout(() => setIsTransitioning(false), 300);
    return () => clearTimeout(timer);
  }, [currentTheme]);

  const containerStyle: React.CSSProperties = {
    padding: '2rem',
    background: theme.background,
    borderRadius: '12px',
    fontFamily: 'system-ui, sans-serif',
    transition: 'all 0.3s ease',
    transform: isTransitioning ? 'scale(0.98)' : 'scale(1)',
    boxShadow: '0 4px 20px rgba(0,0,0,0.15)'
  };

  const buttonStyle = (t: Theme): React.CSSProperties => ({
    padding: '0.75rem 1.25rem',
    margin: '0.25rem',
    border: currentTheme === t ? `2px solid ${theme.primary}` : '2px solid transparent',
    borderRadius: '8px',
    background: currentTheme === t ? theme.accent : 'transparent',
    color: theme.text,
    cursor: 'pointer',
    fontSize: '1rem',
    transition: 'all 0.2s ease',
    outline: 'none'
  });

  const previewStyle: React.CSSProperties = {
    marginTop: '1.5rem',
    padding: '1.5rem',
    background: theme.accent,
    borderRadius: '8px',
    borderLeft: `4px solid ${theme.primary}`
  };

  return (
    <div style={containerStyle}>
      <h3 style={{ color: theme.text, margin: '0 0 0.5rem' }}>
        {theme.emoji} Theme Switcher
      </h3>
      <p style={{ color: theme.text, opacity: 0.8, marginBottom: '1.5rem' }}>
        Click a theme to see smooth transitions powered by React hooks
      </p>

      <div style={{ display: 'flex', flexWrap: 'wrap', gap: '0.5rem' }}>
        {(Object.keys(themes) as Theme[]).map(t => (
          <button
            key={t}
            style={buttonStyle(t)}
            onClick={() => setCurrentTheme(t)}
            onMouseEnter={(e) => {
              if (currentTheme !== t) {
                e.currentTarget.style.background = theme.accent;
              }
            }}
            onMouseLeave={(e) => {
              if (currentTheme !== t) {
                e.currentTarget.style.background = 'transparent';
              }
            }}
          >
            {themes[t].emoji} {themes[t].name}
          </button>
        ))}
      </div>

      <div style={previewStyle}>
        <h4 style={{ color: theme.text, margin: '0 0 0.75rem' }}>
          Preview Card
        </h4>
        <p style={{ color: theme.text, margin: 0, opacity: 0.9 }}>
          This card demonstrates how React's <code style={{ 
            background: theme.primary, 
            color: theme.background,
            padding: '0.1rem 0.4rem',
            borderRadius: '4px'
          }}>useState</code> and <code style={{ 
            background: theme.primary, 
            color: theme.background,
            padding: '0.1rem 0.4rem',
            borderRadius: '4px'
          }}>useEffect</code> hooks enable smooth theme transitions.
        </p>
      </div>

      <div style={{ 
        marginTop: '1rem', 
        padding: '0.75rem',
        background: `${theme.primary}22`,
        borderRadius: '6px',
        fontSize: '0.85rem',
        color: theme.text
      }}>
        <strong>Current:</strong> {theme.name} Theme • 
        <strong> Background:</strong> {theme.background} • 
        <strong> Primary:</strong> {theme.primary}
      </div>
    </div>
  );
}

// Mount the component
const container = document.getElementById('theme-switcher');
if (container) {
  const root = createRoot(container);
  root.render(<ThemeSwitcher />);
}
