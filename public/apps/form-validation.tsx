// Form Validation Demo - Showcases TypeScript generics, type safety, and React forms
import React, { useState, useCallback } from 'react';
import { createRoot } from 'react-dom/client';

// TypeScript interfaces for strong typing
interface FormData {
  username: string;
  email: string;
  password: string;
  confirmPassword: string;
  age: string;
}

interface ValidationErrors {
  username?: string;
  email?: string;
  password?: string;
  confirmPassword?: string;
  age?: string;
}

interface FieldConfig {
  label: string;
  type: string;
  placeholder: string;
  icon: string;
}

// Generic validation function showcasing TypeScript generics
type Validator<T> = (value: T, formData?: FormData) => string | undefined;

const validators: Record<keyof FormData, Validator<string>> = {
  username: (value) => {
    if (!value) return 'Username is required';
    if (value.length < 3) return 'Username must be at least 3 characters';
    if (!/^[a-zA-Z0-9_]+$/.test(value)) return 'Only letters, numbers, and underscores allowed';
    return undefined;
  },
  email: (value) => {
    if (!value) return 'Email is required';
    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value)) return 'Invalid email format';
    return undefined;
  },
  password: (value) => {
    if (!value) return 'Password is required';
    if (value.length < 8) return 'Password must be at least 8 characters';
    if (!/[A-Z]/.test(value)) return 'Password must contain an uppercase letter';
    if (!/[0-9]/.test(value)) return 'Password must contain a number';
    return undefined;
  },
  confirmPassword: (value, formData) => {
    if (!value) return 'Please confirm your password';
    if (formData && value !== formData.password) return 'Passwords do not match';
    return undefined;
  },
  age: (value) => {
    if (!value) return 'Age is required';
    const age = parseInt(value, 10);
    if (isNaN(age)) return 'Age must be a number';
    if (age < 13 || age > 120) return 'Age must be between 13 and 120';
    return undefined;
  }
};

const fieldConfigs: Record<keyof FormData, FieldConfig> = {
  username: { label: 'Username', type: 'text', placeholder: 'johndoe', icon: '👤' },
  email: { label: 'Email', type: 'email', placeholder: 'john@example.com', icon: '📧' },
  password: { label: 'Password', type: 'password', placeholder: '••••••••', icon: '🔒' },
  confirmPassword: { label: 'Confirm Password', type: 'password', placeholder: '••••••••', icon: '🔐' },
  age: { label: 'Age', type: 'number', placeholder: '25', icon: '🎂' }
};

function FormValidation() {
  const [formData, setFormData] = useState<FormData>({
    username: '',
    email: '',
    password: '',
    confirmPassword: '',
    age: ''
  });
  const [errors, setErrors] = useState<ValidationErrors>({});
  const [touched, setTouched] = useState<Record<keyof FormData, boolean>>({
    username: false,
    email: false,
    password: false,
    confirmPassword: false,
    age: false
  });
  const [submitted, setSubmitted] = useState(false);

  const validateField = useCallback((field: keyof FormData, value: string): string | undefined => {
    return validators[field](value, formData);
  }, [formData]);

  const handleChange = (field: keyof FormData) => (e: React.ChangeEvent<HTMLInputElement>) => {
    const newValue = e.target.value;
    setFormData(prev => ({ ...prev, [field]: newValue }));
    
    if (touched[field]) {
      setErrors(prev => ({ ...prev, [field]: validateField(field, newValue) }));
    }
    setSubmitted(false);
  };

  const handleBlur = (field: keyof FormData) => () => {
    setTouched(prev => ({ ...prev, [field]: true }));
    setErrors(prev => ({ ...prev, [field]: validateField(field, formData[field]) }));
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    
    // Validate all fields
    const newErrors: ValidationErrors = {};
    (Object.keys(formData) as Array<keyof FormData>).forEach(field => {
      const error = validateField(field, formData[field]);
      if (error) newErrors[field] = error;
    });
    
    setErrors(newErrors);
    setTouched({
      username: true,
      email: true,
      password: true,
      confirmPassword: true,
      age: true
    });
    
    if (Object.keys(newErrors).length === 0) {
      setSubmitted(true);
    }
  };

  const containerStyle: React.CSSProperties = {
    padding: '2rem',
    background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
    borderRadius: '12px',
    fontFamily: 'system-ui, sans-serif',
    maxWidth: '450px',
    boxShadow: '0 10px 40px rgba(102, 126, 234, 0.4)'
  };

  const formStyle: React.CSSProperties = {
    background: 'white',
    borderRadius: '8px',
    padding: '1.5rem',
    boxShadow: '0 4px 20px rgba(0,0,0,0.1)'
  };

  const inputGroupStyle: React.CSSProperties = {
    marginBottom: '1rem'
  };

  const labelStyle: React.CSSProperties = {
    display: 'block',
    marginBottom: '0.4rem',
    fontWeight: '600',
    color: '#333',
    fontSize: '0.9rem'
  };

  const inputStyle = (hasError: boolean): React.CSSProperties => ({
    width: '100%',
    padding: '0.75rem',
    paddingLeft: '2.5rem',
    border: `2px solid ${hasError ? '#e74c3c' : '#e0e0e0'}`,
    borderRadius: '6px',
    fontSize: '1rem',
    transition: 'border-color 0.2s ease',
    outline: 'none',
    boxSizing: 'border-box'
  });

  const errorStyle: React.CSSProperties = {
    color: '#e74c3c',
    fontSize: '0.8rem',
    marginTop: '0.3rem',
    display: 'flex',
    alignItems: 'center',
    gap: '0.25rem'
  };

  const buttonStyle: React.CSSProperties = {
    width: '100%',
    padding: '0.9rem',
    background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
    color: 'white',
    border: 'none',
    borderRadius: '6px',
    fontSize: '1rem',
    fontWeight: '600',
    cursor: 'pointer',
    transition: 'transform 0.2s ease, box-shadow 0.2s ease'
  };

  const successStyle: React.CSSProperties = {
    background: '#d4edda',
    color: '#155724',
    padding: '1rem',
    borderRadius: '6px',
    textAlign: 'center',
    marginBottom: '1rem',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    gap: '0.5rem'
  };

  return (
    <div style={containerStyle}>
      <h3 style={{ color: 'white', margin: '0 0 1.5rem', textAlign: 'center' }}>
        📝 TypeScript Form Validation
      </h3>
      
      <div style={formStyle}>
        {submitted && (
          <div style={successStyle}>
            <span>✅</span>
            <span>Form submitted successfully!</span>
          </div>
        )}
        
        <form onSubmit={handleSubmit}>
          {(Object.keys(fieldConfigs) as Array<keyof FormData>).map(field => {
            const config = fieldConfigs[field];
            const hasError = touched[field] && !!errors[field];
            
            return (
              <div key={field} style={inputGroupStyle}>
                <label style={labelStyle}>
                  {config.icon} {config.label}
                </label>
                <div style={{ position: 'relative' }}>
                  <input
                    type={config.type}
                    value={formData[field]}
                    onChange={handleChange(field)}
                    onBlur={handleBlur(field)}
                    placeholder={config.placeholder}
                    style={inputStyle(hasError)}
                    onFocus={(e) => e.currentTarget.style.borderColor = '#667eea'}
                  />
                </div>
                {hasError && (
                  <div style={errorStyle}>
                    <span>⚠️</span>
                    <span>{errors[field]}</span>
                  </div>
                )}
              </div>
            );
          })}
          
          <button
            type="submit"
            style={buttonStyle}
            onMouseEnter={(e) => {
              e.currentTarget.style.transform = 'translateY(-2px)';
              e.currentTarget.style.boxShadow = '0 6px 20px rgba(102, 126, 234, 0.4)';
            }}
            onMouseLeave={(e) => {
              e.currentTarget.style.transform = 'translateY(0)';
              e.currentTarget.style.boxShadow = 'none';
            }}
          >
            Create Account
          </button>
        </form>
        
        <div style={{ 
          marginTop: '1rem',
          padding: '0.75rem',
          background: '#f8f9fa',
          borderRadius: '6px',
          fontSize: '0.75rem',
          color: '#666'
        }}>
          💡 <strong>TypeScript Features:</strong> Interfaces, Generics, Record types, Type guards, and strict type checking for form validation
        </div>
      </div>
    </div>
  );
}

// Mount the component
const container = document.getElementById('form-validation');
if (container) {
  const root = createRoot(container);
  root.render(<FormValidation />);
}
