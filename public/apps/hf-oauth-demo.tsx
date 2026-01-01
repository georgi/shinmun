// HuggingFace OAuth Demo - Login and run inference using HF token
// This component demonstrates how to use HF OAuth to authenticate users
// and run inference using the HuggingFace Inference API
import React, { useState, useEffect, useCallback } from 'react';
import { createRoot } from 'react-dom/client';

// Types for OAuth result and user info
interface OAuthResult {
  accessToken: string;
  accessTokenExpiresAt: Date;
  userInfo: UserInfo;
}

interface UserInfo {
  sub: string;
  name: string;
  preferred_username: string;
  picture: string;
  email?: string;
}

// HF OAuth configuration - these would typically come from config
// For production, set up an OAuth app at https://huggingface.co/settings/connected-applications
const HF_OAUTH_CLIENT_ID = (window as any).HF_OAUTH_CLIENT_ID || '';
const HF_OAUTH_SCOPES = 'openid profile inference-api';

// Helper function to generate random string for PKCE
function generateRandomString(): string {
  return crypto.randomUUID() + crypto.randomUUID();
}

// Helper function for base64url encoding
function base64UrlEncode(buffer: ArrayBuffer): string {
  const bytes = new Uint8Array(buffer);
  let binary = '';
  for (let i = 0; i < bytes.length; i++) {
    binary += String.fromCharCode(bytes[i]);
  }
  return btoa(binary)
    .replace(/\+/g, '-')
    .replace(/\//g, '_')
    .replace(/=/g, '');
}

// Generate OAuth login URL with PKCE
async function generateOAuthLoginUrl(): Promise<string> {
  const openidConfigRes = await fetch('https://huggingface.co/.well-known/openid-configuration');
  const openidConfig = await openidConfigRes.json();

  const nonce = crypto.randomUUID();
  const codeVerifier = generateRandomString();

  // Store in localStorage for the callback
  localStorage.setItem('hf_oauth_nonce', nonce);
  localStorage.setItem('hf_oauth_code_verifier', codeVerifier);

  const redirectUri = window.location.href.split('?')[0].split('#')[0];
  const state = JSON.stringify({
    nonce,
    redirectUri,
  });

  // Generate code challenge
  const encoder = new TextEncoder();
  const data = encoder.encode(codeVerifier);
  const digest = await crypto.subtle.digest('SHA-256', data);
  const codeChallenge = base64UrlEncode(digest);

  const params = new URLSearchParams({
    client_id: HF_OAUTH_CLIENT_ID,
    scope: HF_OAUTH_SCOPES,
    response_type: 'code',
    redirect_uri: redirectUri,
    state,
    code_challenge: codeChallenge,
    code_challenge_method: 'S256',
  });

  return `${openidConfig.authorization_endpoint}?${params.toString()}`;
}

// Handle OAuth redirect and exchange code for token
async function handleOAuthRedirect(): Promise<OAuthResult | null> {
  const urlParams = new URLSearchParams(window.location.search);
  const code = urlParams.get('code');
  const stateParam = urlParams.get('state');

  if (!code || !stateParam) {
    return null;
  }

  const codeVerifier = localStorage.getItem('hf_oauth_code_verifier');
  const storedNonce = localStorage.getItem('hf_oauth_nonce');

  if (!codeVerifier || !storedNonce) {
    throw new Error('Missing OAuth state in localStorage');
  }

  // Parse state and verify nonce
  const state = JSON.parse(stateParam);
  if (state.nonce !== storedNonce) {
    throw new Error('OAuth nonce mismatch');
  }

  // Get OpenID configuration
  const openidConfigRes = await fetch('https://huggingface.co/.well-known/openid-configuration');
  const openidConfig = await openidConfigRes.json();

  // Exchange code for token
  const tokenRes = await fetch(openidConfig.token_endpoint, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
    },
    body: new URLSearchParams({
      grant_type: 'authorization_code',
      code,
      redirect_uri: state.redirectUri,
      client_id: HF_OAUTH_CLIENT_ID,
      code_verifier: codeVerifier,
    }),
  });

  if (!tokenRes.ok) {
    throw new Error('Failed to exchange code for token');
  }

  const tokenData = await tokenRes.json();

  // Get user info
  const userInfoRes = await fetch(openidConfig.userinfo_endpoint, {
    headers: {
      Authorization: `Bearer ${tokenData.access_token}`,
    },
  });

  if (!userInfoRes.ok) {
    throw new Error('Failed to get user info');
  }

  const userInfo = await userInfoRes.json();

  // Clean up localStorage
  localStorage.removeItem('hf_oauth_nonce');
  localStorage.removeItem('hf_oauth_code_verifier');

  // Clean up URL
  window.history.replaceState({}, document.title, window.location.pathname);

  // Store the result in session storage
  const result: OAuthResult = {
    accessToken: tokenData.access_token,
    accessTokenExpiresAt: new Date(Date.now() + tokenData.expires_in * 1000),
    userInfo,
  };
  sessionStorage.setItem('hf_oauth_result', JSON.stringify(result));

  return result;
}

// Load saved OAuth result from session storage
function loadSavedOAuthResult(): OAuthResult | null {
  const saved = sessionStorage.getItem('hf_oauth_result');
  if (!saved) return null;

  const result = JSON.parse(saved);
  result.accessTokenExpiresAt = new Date(result.accessTokenExpiresAt);

  // Check if token is expired
  if (result.accessTokenExpiresAt < new Date()) {
    sessionStorage.removeItem('hf_oauth_result');
    return null;
  }

  return result;
}

// Main Demo Component
function HFOAuthDemo() {
  const [oauthResult, setOauthResult] = useState<OAuthResult | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [prompt, setPrompt] = useState('What is the capital of France?');
  const [response, setResponse] = useState<string | null>(null);
  const [isGenerating, setIsGenerating] = useState(false);

  // Handle OAuth redirect on mount
  useEffect(() => {
    async function init() {
      try {
        // First check for redirect
        const redirectResult = await handleOAuthRedirect();
        if (redirectResult) {
          setOauthResult(redirectResult);
          setIsLoading(false);
          return;
        }

        // Then check for saved result
        const savedResult = loadSavedOAuthResult();
        if (savedResult) {
          setOauthResult(savedResult);
        }
      } catch (e) {
        setError(e instanceof Error ? e.message : 'Authentication failed');
      } finally {
        setIsLoading(false);
      }
    }
    init();
  }, []);

  // Handle login button click
  const handleLogin = useCallback(async () => {
    if (!HF_OAUTH_CLIENT_ID) {
      setError('OAuth Client ID not configured. Please set HF_OAUTH_CLIENT_ID.');
      return;
    }
    try {
      setIsLoading(true);
      const loginUrl = await generateOAuthLoginUrl();
      window.location.href = loginUrl;
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Failed to initiate login');
      setIsLoading(false);
    }
  }, []);

  // Handle logout
  const handleLogout = useCallback(() => {
    sessionStorage.removeItem('hf_oauth_result');
    setOauthResult(null);
    setResponse(null);
  }, []);

  // Run inference
  const runInference = useCallback(async () => {
    if (!oauthResult) return;

    setIsGenerating(true);
    setResponse(null);
    setError(null);

    try {
      // Use HF Inference API with the OAuth token
      const res = await fetch('https://api-inference.huggingface.co/models/google/gemma-2-2b-it/v1/chat/completions', {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${oauthResult.accessToken}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          model: 'google/gemma-2-2b-it',
          messages: [{ role: 'user', content: prompt }],
          max_tokens: 500,
        }),
      });

      if (!res.ok) {
        const errorText = await res.text();
        throw new Error(`Inference failed: ${errorText}`);
      }

      const data = await res.json();
      setResponse(data.choices[0].message.content);
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Inference failed');
    } finally {
      setIsGenerating(false);
    }
  }, [oauthResult, prompt]);

  const containerStyle: React.CSSProperties = {
    fontFamily: 'system-ui, -apple-system, sans-serif',
    maxWidth: '600px',
    margin: '0 auto',
  };

  const cardStyle: React.CSSProperties = {
    background: 'white',
    borderRadius: '12px',
    padding: '1.5rem',
    boxShadow: '0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06)',
    marginBottom: '1rem',
  };

  const buttonStyle: React.CSSProperties = {
    display: 'inline-flex',
    alignItems: 'center',
    gap: '0.5rem',
    padding: '0.75rem 1.5rem',
    background: 'linear-gradient(135deg, #FFD21E 0%, #FFB800 100%)',
    color: '#000',
    border: 'none',
    borderRadius: '8px',
    fontSize: '1rem',
    fontWeight: 600,
    cursor: 'pointer',
    transition: 'transform 0.1s, box-shadow 0.1s',
  };

  const secondaryButtonStyle: React.CSSProperties = {
    ...buttonStyle,
    background: '#f3f4f6',
    color: '#374151',
  };

  const primaryButtonStyle: React.CSSProperties = {
    ...buttonStyle,
    background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
    color: 'white',
  };

  if (isLoading) {
    return (
      <div style={containerStyle}>
        <div style={{ ...cardStyle, textAlign: 'center' }}>
          <p>Loading...</p>
        </div>
      </div>
    );
  }

  return (
    <div style={containerStyle}>
      {/* Header */}
      <div style={{ ...cardStyle, background: 'linear-gradient(135deg, #FFD21E 0%, #FF9D00 100%)' }}>
        <h2 style={{ margin: '0 0 0.5rem', display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
          🤗 HuggingFace OAuth Demo
        </h2>
        <p style={{ margin: 0, opacity: 0.8 }}>
          Sign in with HuggingFace to run AI inference directly in your browser
        </p>
      </div>

      {/* Error message */}
      {error && (
        <div style={{ 
          ...cardStyle, 
          background: '#FEE2E2', 
          borderLeft: '4px solid #EF4444',
          display: 'flex',
          alignItems: 'flex-start',
          gap: '0.75rem'
        }}>
          <span style={{ fontSize: '1.25rem' }}>⚠️</span>
          <div>
            <strong style={{ color: '#991B1B' }}>Error</strong>
            <p style={{ margin: '0.25rem 0 0', color: '#991B1B' }}>{error}</p>
          </div>
        </div>
      )}

      {/* Not logged in state */}
      {!oauthResult && !HF_OAUTH_CLIENT_ID && (
        <div style={cardStyle}>
          <h3 style={{ margin: '0 0 1rem' }}>⚙️ Configuration Required</h3>
          <p style={{ color: '#6B7280', margin: '0 0 1rem' }}>
            To use this demo, you need to configure an OAuth Client ID. 
            Create a Developer Application at{' '}
            <a href="https://huggingface.co/settings/connected-applications" target="_blank" rel="noopener noreferrer">
              HuggingFace Settings
            </a>{' '}
            and add the following to your page:
          </p>
          <pre style={{ 
            background: '#1F2937', 
            color: '#E5E7EB', 
            padding: '1rem', 
            borderRadius: '8px',
            overflow: 'auto',
            fontSize: '0.875rem'
          }}>
{`<script>
  window.HF_OAUTH_CLIENT_ID = 'your-client-id';
</script>`}
          </pre>
        </div>
      )}

      {!oauthResult && HF_OAUTH_CLIENT_ID && (
        <div style={cardStyle}>
          <h3 style={{ margin: '0 0 1rem' }}>🔐 Sign In Required</h3>
          <p style={{ color: '#6B7280', margin: '0 0 1rem' }}>
            Sign in with your HuggingFace account to run AI inference. 
            Your token will be used securely to access the HuggingFace Inference API.
          </p>
          <button 
            style={buttonStyle} 
            onClick={handleLogin}
            onMouseOver={(e) => {
              e.currentTarget.style.transform = 'translateY(-2px)';
              e.currentTarget.style.boxShadow = '0 4px 12px rgba(255, 210, 30, 0.4)';
            }}
            onMouseOut={(e) => {
              e.currentTarget.style.transform = '';
              e.currentTarget.style.boxShadow = '';
            }}
          >
            🤗 Sign in with HuggingFace
          </button>
        </div>
      )}

      {/* Logged in state */}
      {oauthResult && (
        <>
          {/* User info */}
          <div style={cardStyle}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '1rem' }}>
              <img 
                src={oauthResult.userInfo.picture} 
                alt={oauthResult.userInfo.name}
                style={{ 
                  width: '48px', 
                  height: '48px', 
                  borderRadius: '50%',
                  border: '2px solid #FFD21E'
                }}
              />
              <div style={{ flex: 1 }}>
                <strong style={{ display: 'block' }}>{oauthResult.userInfo.name}</strong>
                <span style={{ color: '#6B7280', fontSize: '0.875rem' }}>
                  @{oauthResult.userInfo.preferred_username}
                </span>
              </div>
              <button 
                style={secondaryButtonStyle}
                onClick={handleLogout}
              >
                Sign out
              </button>
            </div>
          </div>

          {/* Inference form */}
          <div style={cardStyle}>
            <h3 style={{ margin: '0 0 1rem' }}>🚀 Run Inference</h3>
            <p style={{ color: '#6B7280', margin: '0 0 1rem', fontSize: '0.875rem' }}>
              Using model: <code style={{ background: '#F3F4F6', padding: '0.125rem 0.375rem', borderRadius: '4px' }}>google/gemma-2-2b-it</code>
            </p>
            <textarea
              value={prompt}
              onChange={(e) => setPrompt(e.target.value)}
              placeholder="Enter your prompt..."
              style={{
                width: '100%',
                minHeight: '100px',
                padding: '0.75rem',
                border: '1px solid #E5E7EB',
                borderRadius: '8px',
                fontSize: '1rem',
                fontFamily: 'inherit',
                resize: 'vertical',
                boxSizing: 'border-box',
              }}
            />
            <button
              style={{ ...primaryButtonStyle, marginTop: '1rem', width: '100%', justifyContent: 'center' }}
              onClick={runInference}
              disabled={isGenerating || !prompt.trim()}
            >
              {isGenerating ? '⏳ Generating...' : '✨ Generate Response'}
            </button>

            {/* Response */}
            {response && (
              <div style={{ 
                marginTop: '1rem', 
                padding: '1rem', 
                background: '#F9FAFB', 
                borderRadius: '8px',
                borderLeft: '4px solid #667eea'
              }}>
                <strong style={{ display: 'block', marginBottom: '0.5rem', color: '#667eea' }}>
                  Response:
                </strong>
                <p style={{ margin: 0, whiteSpace: 'pre-wrap', lineHeight: 1.6 }}>{response}</p>
              </div>
            )}
          </div>
        </>
      )}

      {/* Info section */}
      <div style={{ ...cardStyle, background: '#F9FAFB', fontSize: '0.875rem' }}>
        <h4 style={{ margin: '0 0 0.5rem' }}>ℹ️ How it works</h4>
        <ul style={{ margin: 0, paddingLeft: '1.25rem', color: '#6B7280' }}>
          <li>Uses OAuth 2.0 PKCE flow for secure authentication</li>
          <li>Token is stored in sessionStorage (cleared on browser close)</li>
          <li>Inference calls go directly to HuggingFace API</li>
          <li>No server-side code required!</li>
        </ul>
      </div>
    </div>
  );
}

// Mount the component
const container = document.getElementById('hf-oauth-demo');
if (container) {
  const root = createRoot(container);
  root.render(<HFOAuthDemo />);
}
