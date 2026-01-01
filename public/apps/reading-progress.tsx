// Reading Progress Demo - Simulates a blog reading progress indicator
import React, { useState, useEffect, useCallback } from 'react';
import { createRoot } from 'react-dom/client';

interface Section {
  id: string;
  title: string;
  content: string;
}

const sections: Section[] = [
  {
    id: 'intro',
    title: 'Introduction',
    content: 'Welcome to this demo of a reading progress indicator. This component tracks how far you\'ve scrolled through content and provides visual feedback. It\'s a common pattern in modern blogs to help readers understand their progress through longer articles.',
  },
  {
    id: 'features',
    title: 'Key Features',
    content: 'Reading progress indicators typically include a progress bar at the top, estimated reading time, and sometimes section markers. They improve user experience by setting expectations and providing a sense of accomplishment as readers progress through content.',
  },
  {
    id: 'implementation',
    title: 'Implementation',
    content: 'This demo uses React hooks including useState for tracking progress, useEffect for scroll event listeners, and useCallback for optimized event handlers. The progress is calculated based on scroll position relative to content height.',
  },
  {
    id: 'conclusion',
    title: 'Conclusion',
    content: 'Reading progress indicators are a small but impactful UX enhancement for blog posts and long-form content. They\'re especially useful on mobile devices where it\'s harder to gauge document length. Try scrolling this content to see the progress bar in action!',
  },
];

function ReadingProgress() {
  const [progress, setProgress] = useState(0);
  const [activeSection, setActiveSection] = useState(sections[0].id);
  const contentRef = React.useRef<HTMLDivElement>(null);

  const handleScroll = useCallback(() => {
    if (!contentRef.current) return;
    
    const { scrollTop, scrollHeight, clientHeight } = contentRef.current;
    const scrollProgress = (scrollTop / (scrollHeight - clientHeight)) * 100;
    setProgress(Math.min(100, Math.max(0, scrollProgress)));

    // Determine active section
    const sectionElements = contentRef.current.querySelectorAll('[data-section]');
    sectionElements.forEach((el) => {
      const rect = el.getBoundingClientRect();
      const containerRect = contentRef.current!.getBoundingClientRect();
      if (rect.top <= containerRect.top + 100) {
        setActiveSection(el.getAttribute('data-section') || sections[0].id);
      }
    });
  }, []);

  useEffect(() => {
    const content = contentRef.current;
    if (content) {
      content.addEventListener('scroll', handleScroll);
      return () => content.removeEventListener('scroll', handleScroll);
    }
  }, [handleScroll]);

  const estimatedReadTime = 2; // minutes

  const containerStyle: React.CSSProperties = {
    fontFamily: 'system-ui, sans-serif',
    background: '#fff',
    borderRadius: '12px',
    boxShadow: '0 4px 20px rgba(0,0,0,0.1)',
    overflow: 'hidden',
  };

  const headerStyle: React.CSSProperties = {
    padding: '1rem 1.5rem',
    background: '#f8f9fa',
    borderBottom: '1px solid #e9ecef',
  };

  const progressBarContainerStyle: React.CSSProperties = {
    height: '4px',
    background: '#e9ecef',
    borderRadius: '2px',
    overflow: 'hidden',
    marginTop: '0.75rem',
  };

  const progressBarStyle: React.CSSProperties = {
    height: '100%',
    background: 'linear-gradient(90deg, #667eea 0%, #764ba2 100%)',
    width: `${progress}%`,
    transition: 'width 0.1s ease-out',
  };

  const navStyle: React.CSSProperties = {
    display: 'flex',
    gap: '0.5rem',
    flexWrap: 'wrap',
    padding: '0.75rem 1.5rem',
    background: '#f8f9fa',
    borderBottom: '1px solid #e9ecef',
  };

  const navItemStyle = (active: boolean): React.CSSProperties => ({
    padding: '0.35rem 0.75rem',
    fontSize: '0.8rem',
    border: 'none',
    borderRadius: '16px',
    background: active ? '#667eea' : '#e9ecef',
    color: active ? '#fff' : '#666',
    cursor: 'pointer',
    transition: 'all 0.2s ease',
  });

  const contentStyle: React.CSSProperties = {
    height: '300px',
    overflowY: 'auto',
    padding: '1.5rem',
  };

  const sectionStyle: React.CSSProperties = {
    marginBottom: '2rem',
  };

  const handleNavClick = (sectionId: string) => {
    const element = contentRef.current?.querySelector(`[data-section="${sectionId}"]`);
    if (element) {
      element.scrollIntoView({ behavior: 'smooth', block: 'start' });
    }
  };

  return (
    <div style={containerStyle}>
      <div style={headerStyle}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <h3 style={{ margin: 0, color: '#333' }}>📖 Blog Post Demo</h3>
          <div style={{ display: 'flex', alignItems: 'center', gap: '1rem' }}>
            <span style={{ fontSize: '0.85rem', color: '#666' }}>
              ⏱️ {estimatedReadTime} min read
            </span>
            <span style={{ 
              fontSize: '0.85rem', 
              fontWeight: '600',
              color: '#667eea'
            }}>
              {Math.round(progress)}%
            </span>
          </div>
        </div>
        <div style={progressBarContainerStyle}>
          <div style={progressBarStyle} />
        </div>
      </div>

      <div style={navStyle}>
        {sections.map(section => (
          <button
            key={section.id}
            style={navItemStyle(activeSection === section.id)}
            onClick={() => handleNavClick(section.id)}
          >
            {section.title}
          </button>
        ))}
      </div>

      <div ref={contentRef} style={contentStyle}>
        {sections.map(section => (
          <div key={section.id} data-section={section.id} style={sectionStyle}>
            <h4 style={{ color: '#333', marginBottom: '0.75rem' }}>
              {section.title}
            </h4>
            <p style={{ color: '#555', lineHeight: '1.7', margin: 0 }}>
              {section.content}
            </p>
          </div>
        ))}
        
        <div style={{
          padding: '1.5rem',
          background: 'linear-gradient(135deg, #667eea22 0%, #764ba222 100%)',
          borderRadius: '8px',
          textAlign: 'center',
        }}>
          <span style={{ fontSize: '2rem' }}>🎉</span>
          <p style={{ color: '#667eea', fontWeight: '600', margin: '0.5rem 0 0' }}>
            You've reached the end!
          </p>
        </div>
      </div>

      <div style={{
        padding: '0.75rem 1.5rem',
        background: '#e0f2fe',
        fontSize: '0.8rem',
        color: '#0369a1',
        textAlign: 'center'
      }}>
        💡 <strong>React Hooks:</strong> <code>useState</code> for progress, <code>useEffect</code> for scroll listener, <code>useCallback</code> for optimized handler
      </div>
    </div>
  );
}

// Mount the component
const container = document.getElementById('reading-progress');
if (container) {
  const root = createRoot(container);
  root.render(<ReadingProgress />);
}
