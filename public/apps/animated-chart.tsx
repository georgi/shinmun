// Animated Bar Chart Demo - Interactive data visualization with React
import React, { useState, useEffect } from 'react';
import { createRoot } from 'react-dom/client';

interface DataPoint {
  label: string;
  value: number;
  color: string;
}

const generateRandomData = (): DataPoint[] => [
  { label: 'React', value: Math.floor(Math.random() * 80) + 20, color: '#61dafb' },
  { label: 'Vue', value: Math.floor(Math.random() * 80) + 20, color: '#42b883' },
  { label: 'Angular', value: Math.floor(Math.random() * 80) + 20, color: '#dd0031' },
  { label: 'Svelte', value: Math.floor(Math.random() * 80) + 20, color: '#ff3e00' },
  { label: 'Solid', value: Math.floor(Math.random() * 80) + 20, color: '#446b9e' }
];

function AnimatedChart() {
  const [data, setData] = useState<DataPoint[]>(generateRandomData);
  const [isAnimating, setIsAnimating] = useState(false);
  const [autoUpdate, setAutoUpdate] = useState(false);

  useEffect(() => {
    if (!autoUpdate) return;
    
    const interval = setInterval(() => {
      setIsAnimating(true);
      setTimeout(() => {
        setData(generateRandomData());
        setIsAnimating(false);
      }, 200);
    }, 2000);

    return () => clearInterval(interval);
  }, [autoUpdate]);

  const maxValue = Math.max(...data.map(d => d.value));

  const containerStyle: React.CSSProperties = {
    padding: '1.5rem',
    background: 'linear-gradient(135deg, #1a1a2e 0%, #16213e 100%)',
    borderRadius: '12px',
    fontFamily: 'system-ui, sans-serif',
    color: '#fff',
    boxShadow: '0 8px 32px rgba(0,0,0,0.3)'
  };

  const barContainerStyle: React.CSSProperties = {
    display: 'flex',
    alignItems: 'flex-end',
    justifyContent: 'space-around',
    height: '200px',
    padding: '1rem 0',
    borderBottom: '2px solid rgba(255,255,255,0.2)'
  };

  const barStyle = (point: DataPoint): React.CSSProperties => ({
    width: '60px',
    height: `${(point.value / maxValue) * 160}px`,
    background: `linear-gradient(180deg, ${point.color} 0%, ${point.color}88 100%)`,
    borderRadius: '8px 8px 0 0',
    transition: 'height 0.5s cubic-bezier(0.4, 0, 0.2, 1)',
    transform: isAnimating ? 'scaleY(0.1)' : 'scaleY(1)',
    transformOrigin: 'bottom',
    display: 'flex',
    flexDirection: 'column',
    justifyContent: 'flex-start',
    alignItems: 'center',
    position: 'relative',
    boxShadow: `0 0 20px ${point.color}44`
  });

  const buttonStyle = (active: boolean = false): React.CSSProperties => ({
    padding: '0.6rem 1.2rem',
    margin: '0.25rem',
    border: 'none',
    borderRadius: '6px',
    background: active ? '#e94560' : 'rgba(255,255,255,0.1)',
    color: '#fff',
    cursor: 'pointer',
    fontSize: '0.9rem',
    transition: 'all 0.2s ease',
    outline: 'none'
  });

  return (
    <div style={containerStyle}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '1rem' }}>
        <h3 style={{ margin: 0 }}>📊 Framework Popularity</h3>
        <span style={{ opacity: 0.7, fontSize: '0.85rem' }}>
          {autoUpdate ? '🔄 Auto-updating...' : 'Click Randomize'}
        </span>
      </div>

      <div style={barContainerStyle}>
        {data.map((point, index) => (
          <div key={point.label} style={{ textAlign: 'center' }}>
            <div style={barStyle(point)}>
              <span style={{ 
                position: 'absolute',
                top: '-25px',
                fontWeight: 'bold',
                fontSize: '0.9rem',
                textShadow: '0 2px 4px rgba(0,0,0,0.5)'
              }}>
                {point.value}%
              </span>
            </div>
            <div style={{ 
              marginTop: '0.75rem', 
              fontSize: '0.85rem',
              fontWeight: '500',
              color: point.color
            }}>
              {point.label}
            </div>
          </div>
        ))}
      </div>

      <div style={{ marginTop: '1.5rem', display: 'flex', justifyContent: 'center', flexWrap: 'wrap' }}>
        <button
          style={buttonStyle()}
          onClick={() => {
            setIsAnimating(true);
            setTimeout(() => {
              setData(generateRandomData());
              setIsAnimating(false);
            }, 200);
          }}
          onMouseEnter={(e) => e.currentTarget.style.background = 'rgba(255,255,255,0.2)'}
          onMouseLeave={(e) => e.currentTarget.style.background = 'rgba(255,255,255,0.1)'}
        >
          🎲 Randomize
        </button>
        <button
          style={buttonStyle(autoUpdate)}
          onClick={() => setAutoUpdate(!autoUpdate)}
        >
          {autoUpdate ? '⏹️ Stop Auto' : '▶️ Auto Update'}
        </button>
        <button
          style={buttonStyle()}
          onClick={() => {
            setData(data.map(d => ({ ...d, value: 50 })));
          }}
          onMouseEnter={(e) => e.currentTarget.style.background = 'rgba(255,255,255,0.2)'}
          onMouseLeave={(e) => e.currentTarget.style.background = 'rgba(255,255,255,0.1)'}
        >
          ⚖️ Equalize
        </button>
      </div>

      <div style={{ 
        marginTop: '1rem',
        padding: '0.75rem',
        background: 'rgba(255,255,255,0.05)',
        borderRadius: '6px',
        fontSize: '0.8rem',
        textAlign: 'center',
        opacity: 0.8
      }}>
        💡 This demo uses <code style={{ color: '#61dafb' }}>useState</code> for data, <code style={{ color: '#61dafb' }}>useEffect</code> for auto-update, and CSS transitions for smooth animations
      </div>
    </div>
  );
}

// Mount the component
const container = document.getElementById('animated-chart');
if (container) {
  const root = createRoot(container);
  root.render(<AnimatedChart />);
}
