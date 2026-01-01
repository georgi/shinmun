---
title: HuggingFace OAuth Demo
---
This page demonstrates how to integrate HuggingFace OAuth authentication in your Shinmun blog, allowing visitors to sign in with their HuggingFace account and run AI inference directly in the browser.

## Live Demo

Try the HuggingFace OAuth login below. Once signed in, you can use your HuggingFace token to run inference:

    @@typescript-file[hf-oauth-demo](public/apps/hf-oauth-demo.tsx)

---

## What is HuggingFace OAuth?

HuggingFace provides OAuth 2.0 authentication that allows third-party applications to authenticate users and access HuggingFace services on their behalf. This is perfect for:

- **Blog visitors** who want to interact with AI models directly on your site
- **Demo applications** that showcase AI capabilities without server-side infrastructure
- **Educational content** that lets readers experiment with models hands-on

---

## How It Works

### 1. OAuth 2.0 PKCE Flow

The demo uses the Proof Key for Code Exchange (PKCE) flow, which is secure for client-side applications:

```
┌─────────┐                                      ┌──────────────┐
│  User   │                                      │  HuggingFace │
└────┬────┘                                      └──────┬───────┘
     │                                                  │
     │  1. Click "Sign in with HuggingFace"             │
     │ ────────────────────────────────────────────────>│
     │                                                  │
     │  2. HF shows consent screen                      │
     │ <────────────────────────────────────────────────│
     │                                                  │
     │  3. User approves, redirected back with code     │
     │ ────────────────────────────────────────────────>│
     │                                                  │
     │  4. Exchange code for access token               │
     │ <────────────────────────────────────────────────│
     │                                                  │
     │  5. Use token for HF Inference API               │
     │ ────────────────────────────────────────────────>│
     │                                                  │
     │  6. Get AI response                              │
     │ <────────────────────────────────────────────────│
```

### 2. Token Storage

- Access tokens are stored in `sessionStorage` (cleared when browser closes)
- Code verifier and nonce for PKCE are stored temporarily in `localStorage`
- No server-side token storage required

### 3. Inference API

Once authenticated, users can call the HuggingFace Inference API directly from the browser using their OAuth token.

---

## Setting Up OAuth for Your Blog

### Step 1: Create a Developer Application

1. Go to [HuggingFace Settings > Connected Applications](https://huggingface.co/settings/connected-applications)
2. Click "Create new application"
3. Fill in:
   - **Application name**: Your blog name
   - **Redirect URLs**: Your blog URL (e.g., `https://yourblog.com/hf-oauth-demo`)
   - **Scopes**: `openid profile inference-api`
4. Save and copy the **Client ID**

### Step 2: Configure Your Page

Add the OAuth Client ID to your page before loading the component. You can do this in your layout template or directly in the page:

```html
<script>
  window.HF_OAUTH_CLIENT_ID = 'your-client-id-here';
  // Optional: customize the inference model (defaults to 'google/gemma-2-2b-it')
  window.HF_INFERENCE_MODEL = 'your-preferred-model';
</script>
```

### Step 3: Add the Demo Component

Reference the component in your markdown page:

```markdown
    @@typescript-file[hf-oauth-demo](public/apps/hf-oauth-demo.tsx)
```

---

## Customizing the Component

### Change the Model

You can easily change the model without editing the component by setting `window.HF_INFERENCE_MODEL` before the component loads:

```html
<script>
  window.HF_INFERENCE_MODEL = 'meta-llama/Llama-3.2-1B-Instruct';
</script>
```

Alternatively, edit `hf-oauth-demo.tsx` and update the `DEFAULT_MODEL` constant.

### Change OAuth Scopes

Available scopes include:
- `openid` - Required for OAuth
- `profile` - Access to user profile information
- `email` - Access to user email
- `inference-api` - Access to HuggingFace Inference API
- `read-repos` - Read access to user's repositories

Update the scope in the component:

```typescript
const HF_OAUTH_SCOPES = 'openid profile inference-api email';
```

---

## Security Considerations

### Best Practices

1. **Use PKCE**: The demo uses PKCE flow which is secure for browser-based apps
2. **Session storage**: Tokens are stored in sessionStorage and cleared on browser close
3. **Minimal scopes**: Request only the scopes you need
4. **HTTPS**: Always use HTTPS in production

### Token Expiration

OAuth tokens have an expiration time (typically 1 hour). The demo checks expiration and requires re-authentication when expired.

### User Privacy

- User information is fetched from HuggingFace's userinfo endpoint
- No data is sent to your server - everything runs client-side
- Users can revoke access anytime from their HuggingFace settings

---

## API Reference

### Functions

#### `generateOAuthLoginUrl()`
Generates the HuggingFace OAuth login URL with PKCE parameters.

```typescript
const loginUrl = await generateOAuthLoginUrl();
window.location.href = loginUrl;
```

#### `handleOAuthRedirect()`
Handles the OAuth callback, exchanges the authorization code for an access token.

```typescript
const result = await handleOAuthRedirect();
if (result) {
  console.log('Logged in as:', result.userInfo.name);
  console.log('Token:', result.accessToken);
}
```

#### `loadSavedOAuthResult()`
Loads a previously saved OAuth result from session storage.

```typescript
const saved = loadSavedOAuthResult();
if (saved && saved.accessTokenExpiresAt > new Date()) {
  // Still valid
}
```

### Types

```typescript
interface OAuthResult {
  accessToken: string;
  accessTokenExpiresAt: Date;
  userInfo: UserInfo;
}

interface UserInfo {
  sub: string;           // Unique user ID
  name: string;          // Display name
  preferred_username: string;  // Username
  picture: string;       // Avatar URL
  email?: string;        // Email (if scope granted)
}
```

---

## Troubleshooting

### "OAuth Client ID not configured"

Make sure you've set `window.HF_OAUTH_CLIENT_ID` before the component loads.

### "Redirect URI mismatch"

Ensure the redirect URL in your HuggingFace application settings matches your page URL exactly.

### "Token expired"

OAuth tokens expire after ~1 hour. Users will need to sign in again.

### CORS errors

The HuggingFace API supports CORS for browser requests. If you see CORS errors, ensure you're using the correct endpoints.

---

## Resources

- [HuggingFace OAuth Documentation](https://huggingface.co/docs/hub/oauth)
- [HuggingFace Inference API](https://huggingface.co/docs/api-inference)
- [HuggingFace.js Library](https://huggingface.co/docs/huggingface.js)
- [OAuth 2.0 PKCE RFC](https://datatracker.ietf.org/doc/html/rfc7636)
