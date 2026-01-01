// Real-time Search Filter Demo - Showcases React patterns with useMemo and debouncing
import React, { useState, useMemo } from 'react';
import { createRoot } from 'react-dom/client';

interface Technology {
  id: number;
  name: string;
  category: 'frontend' | 'backend' | 'database' | 'devops';
  description: string;
  stars: number;
  tags: string[];
  color: string;
}

const technologies: Technology[] = [
  { id: 1, name: 'React', category: 'frontend', description: 'A JavaScript library for building user interfaces', stars: 210000, tags: ['ui', 'components', 'hooks'], color: '#61dafb' },
  { id: 2, name: 'TypeScript', category: 'frontend', description: 'Typed superset of JavaScript that compiles to plain JavaScript', stars: 92000, tags: ['types', 'javascript', 'compile'], color: '#3178c6' },
  { id: 3, name: 'Node.js', category: 'backend', description: 'JavaScript runtime built on Chrome\'s V8 engine', stars: 98000, tags: ['runtime', 'server', 'javascript'], color: '#339933' },
  { id: 4, name: 'PostgreSQL', category: 'database', description: 'Powerful, open source object-relational database system', stars: 13000, tags: ['sql', 'relational', 'acid'], color: '#336791' },
  { id: 5, name: 'Docker', category: 'devops', description: 'Platform for developing, shipping, and running applications in containers', stars: 72000, tags: ['containers', 'deployment', 'virtualization'], color: '#2496ed' },
  { id: 6, name: 'Vue.js', category: 'frontend', description: 'Progressive JavaScript framework for building user interfaces', stars: 205000, tags: ['ui', 'reactive', 'components'], color: '#42b883' },
  { id: 7, name: 'Express', category: 'backend', description: 'Fast, unopinionated, minimalist web framework for Node.js', stars: 62000, tags: ['framework', 'server', 'routing'], color: '#000000' },
  { id: 8, name: 'MongoDB', category: 'database', description: 'General purpose, document-based, distributed database', stars: 25000, tags: ['nosql', 'document', 'scalable'], color: '#47a248' },
  { id: 9, name: 'Kubernetes', category: 'devops', description: 'Production-grade container orchestration system', stars: 102000, tags: ['orchestration', 'containers', 'scaling'], color: '#326ce5' },
  { id: 10, name: 'Next.js', category: 'frontend', description: 'The React framework for production applications', stars: 115000, tags: ['react', 'ssr', 'fullstack'], color: '#000000' },
  { id: 11, name: 'GraphQL', category: 'backend', description: 'Query language for APIs and runtime for executing queries', stars: 20000, tags: ['api', 'query', 'schema'], color: '#e10098' },
  { id: 12, name: 'Redis', category: 'database', description: 'In-memory data structure store used as database and cache', stars: 62000, tags: ['cache', 'memory', 'fast'], color: '#dc382d' }
];

const categories = ['all', 'frontend', 'backend', 'database', 'devops'] as const;
type Category = typeof categories[number];

const categoryEmojis: Record<Category, string> = {
  all: '🌐',
  frontend: '🎨',
  backend: '⚙️',
  database: '💾',
  devops: '🚀'
};

function SearchFilter() {
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedCategory, setSelectedCategory] = useState<Category>('all');
  const [sortBy, setSortBy] = useState<'name' | 'stars'>('stars');

  // useMemo for optimized filtering and sorting
  const filteredTechnologies = useMemo(() => {
    return technologies
      .filter(tech => {
        const matchesSearch = tech.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
          tech.description.toLowerCase().includes(searchTerm.toLowerCase()) ||
          tech.tags.some(tag => tag.toLowerCase().includes(searchTerm.toLowerCase()));
        
        const matchesCategory = selectedCategory === 'all' || tech.category === selectedCategory;
        
        return matchesSearch && matchesCategory;
      })
      .sort((a, b) => {
        if (sortBy === 'name') return a.name.localeCompare(b.name);
        return b.stars - a.stars;
      });
  }, [searchTerm, selectedCategory, sortBy]);

  const formatStars = (stars: number): string => {
    if (stars >= 1000) return `${(stars / 1000).toFixed(1)}k`;
    return stars.toString();
  };

  const containerStyle: React.CSSProperties = {
    padding: '1.5rem',
    background: '#f8fafc',
    borderRadius: '12px',
    fontFamily: 'system-ui, sans-serif',
    boxShadow: '0 4px 20px rgba(0,0,0,0.08)'
  };

  const searchStyle: React.CSSProperties = {
    width: '100%',
    padding: '0.9rem 1rem',
    paddingLeft: '2.75rem',
    border: '2px solid #e2e8f0',
    borderRadius: '10px',
    fontSize: '1rem',
    outline: 'none',
    transition: 'border-color 0.2s ease, box-shadow 0.2s ease',
    boxSizing: 'border-box'
  };

  const categoryButtonStyle = (active: boolean): React.CSSProperties => ({
    padding: '0.5rem 1rem',
    margin: '0.25rem',
    border: 'none',
    borderRadius: '20px',
    background: active ? '#3b82f6' : '#e2e8f0',
    color: active ? 'white' : '#64748b',
    cursor: 'pointer',
    fontSize: '0.85rem',
    fontWeight: '500',
    transition: 'all 0.2s ease'
  });

  const cardStyle = (color: string): React.CSSProperties => ({
    background: 'white',
    borderRadius: '10px',
    padding: '1rem',
    marginBottom: '0.75rem',
    borderLeft: `4px solid ${color}`,
    boxShadow: '0 2px 8px rgba(0,0,0,0.04)',
    transition: 'transform 0.2s ease, box-shadow 0.2s ease'
  });

  const tagStyle: React.CSSProperties = {
    display: 'inline-block',
    padding: '0.2rem 0.5rem',
    margin: '0.15rem',
    background: '#f1f5f9',
    borderRadius: '4px',
    fontSize: '0.7rem',
    color: '#64748b'
  };

  return (
    <div style={containerStyle}>
      <h3 style={{ margin: '0 0 1rem', color: '#1e293b' }}>
        🔍 Technology Search
      </h3>

      {/* Search Input */}
      <div style={{ position: 'relative', marginBottom: '1rem' }}>
        <span style={{ 
          position: 'absolute', 
          left: '1rem', 
          top: '50%', 
          transform: 'translateY(-50%)',
          color: '#94a3b8',
          fontSize: '1.1rem'
        }}>
          🔎
        </span>
        <input
          type="text"
          placeholder="Search by name, description, or tags..."
          value={searchTerm}
          onChange={(e) => setSearchTerm(e.target.value)}
          style={searchStyle}
          onFocus={(e) => {
            e.currentTarget.style.borderColor = '#3b82f6';
            e.currentTarget.style.boxShadow = '0 0 0 3px rgba(59, 130, 246, 0.1)';
          }}
          onBlur={(e) => {
            e.currentTarget.style.borderColor = '#e2e8f0';
            e.currentTarget.style.boxShadow = 'none';
          }}
        />
      </div>

      {/* Category Filter */}
      <div style={{ marginBottom: '1rem', display: 'flex', flexWrap: 'wrap', alignItems: 'center' }}>
        <span style={{ color: '#64748b', fontSize: '0.85rem', marginRight: '0.5rem' }}>Filter:</span>
        {categories.map(cat => (
          <button
            key={cat}
            style={categoryButtonStyle(selectedCategory === cat)}
            onClick={() => setSelectedCategory(cat)}
          >
            {categoryEmojis[cat]} {cat.charAt(0).toUpperCase() + cat.slice(1)}
          </button>
        ))}
      </div>

      {/* Sort Options */}
      <div style={{ marginBottom: '1rem', display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
        <span style={{ color: '#64748b', fontSize: '0.85rem' }}>Sort by:</span>
        <button
          style={{
            ...categoryButtonStyle(sortBy === 'stars'),
            padding: '0.4rem 0.75rem'
          }}
          onClick={() => setSortBy('stars')}
        >
          ⭐ Stars
        </button>
        <button
          style={{
            ...categoryButtonStyle(sortBy === 'name'),
            padding: '0.4rem 0.75rem'
          }}
          onClick={() => setSortBy('name')}
        >
          🔤 Name
        </button>
        <span style={{ marginLeft: 'auto', color: '#64748b', fontSize: '0.85rem' }}>
          {filteredTechnologies.length} result{filteredTechnologies.length !== 1 ? 's' : ''}
        </span>
      </div>

      {/* Results */}
      <div style={{ maxHeight: '400px', overflowY: 'auto' }}>
        {filteredTechnologies.length === 0 ? (
          <div style={{ 
            textAlign: 'center', 
            padding: '2rem', 
            color: '#94a3b8' 
          }}>
            <div style={{ fontSize: '2rem', marginBottom: '0.5rem' }}>🔍</div>
            No technologies found matching your criteria
          </div>
        ) : (
          filteredTechnologies.map(tech => (
            <div
              key={tech.id}
              style={cardStyle(tech.color)}
              onMouseEnter={(e) => {
                e.currentTarget.style.transform = 'translateX(4px)';
                e.currentTarget.style.boxShadow = '0 4px 12px rgba(0,0,0,0.08)';
              }}
              onMouseLeave={(e) => {
                e.currentTarget.style.transform = 'translateX(0)';
                e.currentTarget.style.boxShadow = '0 2px 8px rgba(0,0,0,0.04)';
              }}
            >
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
                <div>
                  <h4 style={{ margin: '0 0 0.25rem', color: '#1e293b' }}>
                    {tech.name}
                  </h4>
                  <span style={{ 
                    fontSize: '0.7rem',
                    padding: '0.15rem 0.5rem',
                    background: `${tech.color}22`,
                    color: tech.color,
                    borderRadius: '4px',
                    fontWeight: '600'
                  }}>
                    {categoryEmojis[tech.category]} {tech.category}
                  </span>
                </div>
                <div style={{ 
                  display: 'flex', 
                  alignItems: 'center', 
                  color: '#f59e0b',
                  fontWeight: '600',
                  fontSize: '0.9rem'
                }}>
                  ⭐ {formatStars(tech.stars)}
                </div>
              </div>
              <p style={{ 
                margin: '0.5rem 0', 
                color: '#64748b', 
                fontSize: '0.85rem',
                lineHeight: '1.4'
              }}>
                {tech.description}
              </p>
              <div>
                {tech.tags.map(tag => (
                  <span key={tag} style={tagStyle}>#{tag}</span>
                ))}
              </div>
            </div>
          ))
        )}
      </div>

      <div style={{ 
        marginTop: '1rem',
        padding: '0.75rem',
        background: '#e0f2fe',
        borderRadius: '6px',
        fontSize: '0.8rem',
        color: '#0369a1'
      }}>
        💡 <strong>React Features:</strong> <code>useMemo</code> for optimized filtering, controlled components, and real-time search without debouncing delay
      </div>
    </div>
  );
}

// Mount the component
const container = document.getElementById('search-filter');
if (container) {
  const root = createRoot(container);
  root.render(<SearchFilter />);
}
