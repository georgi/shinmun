// Photo Gallery Demo - Interactive image gallery with React
import React, { useState } from 'react';
import { createRoot } from 'react-dom/client';

interface Photo {
  id: number;
  title: string;
  category: string;
  color: string;
}

const photos: Photo[] = [
  { id: 1, title: 'Mountain Sunrise', category: 'nature', color: '#ff6b6b' },
  { id: 2, title: 'City Lights', category: 'urban', color: '#4ecdc4' },
  { id: 3, title: 'Ocean Waves', category: 'nature', color: '#45b7d1' },
  { id: 4, title: 'Forest Path', category: 'nature', color: '#96ceb4' },
  { id: 5, title: 'Street Art', category: 'urban', color: '#dda0dd' },
  { id: 6, title: 'Desert Dunes', category: 'nature', color: '#f4a460' },
  { id: 7, title: 'Neon Signs', category: 'urban', color: '#ff69b4' },
  { id: 8, title: 'Waterfall', category: 'nature', color: '#00ced1' },
  { id: 9, title: 'Rooftop View', category: 'urban', color: '#9370db' },
];

type Category = 'all' | 'nature' | 'urban';

function PhotoGallery() {
  const [selectedPhoto, setSelectedPhoto] = useState<Photo | null>(null);
  const [category, setCategory] = useState<Category>('all');

  const filteredPhotos = category === 'all' 
    ? photos 
    : photos.filter(p => p.category === category);

  const containerStyle: React.CSSProperties = {
    padding: '1.5rem',
    background: '#1a1a2e',
    borderRadius: '12px',
    fontFamily: 'system-ui, sans-serif',
    color: '#fff',
  };

  const filterStyle = (active: boolean): React.CSSProperties => ({
    padding: '0.5rem 1rem',
    margin: '0.25rem',
    border: 'none',
    borderRadius: '20px',
    background: active ? '#e94560' : 'rgba(255,255,255,0.1)',
    color: '#fff',
    cursor: 'pointer',
    fontSize: '0.9rem',
    transition: 'all 0.2s ease',
  });

  const gridStyle: React.CSSProperties = {
    display: 'grid',
    gridTemplateColumns: 'repeat(auto-fill, minmax(150px, 1fr))',
    gap: '1rem',
    marginTop: '1rem',
  };

  const photoStyle = (photo: Photo): React.CSSProperties => ({
    aspectRatio: '1',
    background: `linear-gradient(135deg, ${photo.color} 0%, ${photo.color}88 100%)`,
    borderRadius: '8px',
    cursor: 'pointer',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    fontSize: '2rem',
    transition: 'transform 0.2s ease, box-shadow 0.2s ease',
    position: 'relative',
    overflow: 'hidden',
  });

  const overlayStyle: React.CSSProperties = {
    position: 'fixed',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    background: 'rgba(0,0,0,0.9)',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    zIndex: 1000,
    cursor: 'pointer',
  };

  const modalStyle = (photo: Photo): React.CSSProperties => ({
    width: '80%',
    maxWidth: '500px',
    aspectRatio: '4/3',
    background: `linear-gradient(135deg, ${photo.color} 0%, ${photo.color}88 100%)`,
    borderRadius: '12px',
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'center',
    justifyContent: 'center',
    padding: '2rem',
    animation: 'fadeIn 0.2s ease',
  });

  const getEmoji = (category: string) => category === 'nature' ? '🏞️' : '🌆';

  return (
    <div style={containerStyle}>
      <h3 style={{ margin: '0 0 1rem' }}>📸 Photo Gallery</h3>
      
      <div>
        {(['all', 'nature', 'urban'] as Category[]).map(cat => (
          <button
            key={cat}
            style={filterStyle(category === cat)}
            onClick={() => setCategory(cat)}
          >
            {cat === 'all' ? '🌐 All' : cat === 'nature' ? '🏞️ Nature' : '🌆 Urban'}
          </button>
        ))}
      </div>

      <div style={gridStyle}>
        {filteredPhotos.map(photo => (
          <div
            key={photo.id}
            style={photoStyle(photo)}
            onClick={() => setSelectedPhoto(photo)}
            onMouseEnter={(e) => {
              e.currentTarget.style.transform = 'scale(1.05)';
              e.currentTarget.style.boxShadow = `0 8px 25px ${photo.color}66`;
            }}
            onMouseLeave={(e) => {
              e.currentTarget.style.transform = 'scale(1)';
              e.currentTarget.style.boxShadow = 'none';
            }}
          >
            <span>{getEmoji(photo.category)}</span>
            <div style={{
              position: 'absolute',
              bottom: 0,
              left: 0,
              right: 0,
              padding: '0.5rem',
              background: 'rgba(0,0,0,0.5)',
              fontSize: '0.7rem',
              textAlign: 'center',
            }}>
              {photo.title}
            </div>
          </div>
        ))}
      </div>

      {selectedPhoto && (
        <div style={overlayStyle} onClick={() => setSelectedPhoto(null)}>
          <div style={modalStyle(selectedPhoto)} onClick={(e) => e.stopPropagation()}>
            <span style={{ fontSize: '4rem', marginBottom: '1rem' }}>
              {getEmoji(selectedPhoto.category)}
            </span>
            <h2 style={{ margin: '0 0 0.5rem' }}>{selectedPhoto.title}</h2>
            <p style={{ margin: 0, opacity: 0.8, textTransform: 'capitalize' }}>
              {selectedPhoto.category} Photography
            </p>
            <button
              style={{
                marginTop: '1.5rem',
                padding: '0.5rem 1.5rem',
                background: 'rgba(255,255,255,0.2)',
                border: '2px solid white',
                borderRadius: '20px',
                color: 'white',
                cursor: 'pointer',
              }}
              onClick={() => setSelectedPhoto(null)}
            >
              Close
            </button>
          </div>
        </div>
      )}

      <div style={{
        marginTop: '1rem',
        padding: '0.75rem',
        background: 'rgba(255,255,255,0.05)',
        borderRadius: '6px',
        fontSize: '0.8rem',
        textAlign: 'center',
        opacity: 0.8
      }}>
        💡 Click any photo to view it in a lightbox modal
      </div>
    </div>
  );
}

// Mount the component
const container = document.getElementById('photo-gallery');
if (container) {
  const root = createRoot(container);
  root.render(<PhotoGallery />);
}
