# Hidden API (Experimental)

!!! warning "Unsupported & Experimental"
    The Hidden API functionality accesses **internal NMM web portal endpoints** that are **not part of the official public API**.

    - These endpoints may change **without notice**
    - They could **break at any time** with NMM updates
    - **No support** is provided for these features
    - Use entirely **at your own risk**

## Overview

The Hidden API allows you to access internal NMM web portal APIs that are not exposed through the official REST API. This can be useful for:

- Accessing features not yet available in the public API
- Automation tasks that require portal-only functionality
- Advanced integrations

## How It Works

The Hidden API uses browser cookie authentication to access the same internal APIs that the NMM web portal uses. The process involves:

1. Logging into NMM through your browser
2. Capturing the authentication cookies
3. Using those cookies to make API requests from PowerShell

## Prerequisites

- NMM-PS module installed
- Access to the NMM web portal
- Chrome, Edge, or Brave browser
- (Recommended) The NMM-PS Browser Extension

---

## Browser Extension Setup

The browser extension makes cookie capture seamless by automatically extracting cookies and sending them to PowerShell.

### Installation

1. Download or clone the NMM-PS repository
2. Open your browser's extension page:
   - **Chrome**: `chrome://extensions`
   - **Edge**: `edge://extensions`
   - **Brave**: `brave://extensions`
3. Enable **Developer mode** (toggle in the top-right corner)
4. Click **Load unpacked**
5. Select the `BrowserExtension` folder from the repository
6. The NMM-PS icon should appear in your toolbar

!!! warning "Security Note"
    The extension only sends cookies to `localhost` - your credentials never leave your machine. It only captures cookies from NMM domains.

### Extension Features

- **Automatic cookie capture** - Gets all cookies including HttpOnly ones
- **One-click send** - Sends cookies directly to PowerShell listener
- **Copy option** - Manual clipboard copy as backup
- **Domain validation** - Only works on NMM domains

---

## Usage

### Method 1: Browser Extension (Recommended)

```powershell
# Start the listener and open browser
Connect-NMMHiddenApi
```

This will:

1. Start a local HTTP listener on port 19847
2. Open your NMM portal in the browser

Then:

1. Log into NMM in the browser
2. Click the **NMM-PS** extension icon in your toolbar
3. Click **"Send Cookies to PowerShell"**
4. The PowerShell command will complete automatically

Now you can make requests:

```powershell
# Get accounts
Invoke-HiddenApiRequest -Method GET -Endpoint "accounts"

# POST with body
Invoke-HiddenApiRequest -Method POST -Endpoint "some/endpoint" -Body @{
    key = "value"
}

# Call a full URL directly
Invoke-HiddenApiRequest -Method GET -Uri "https://your-nmm.nerdio.net/api/v1/msp/some/endpoint"
```

### Method 2: Manual Cookie Copy

If you prefer not to use the extension:

1. Install the [Cookie-Editor](https://cookie-editor.cgagnier.ca/) browser extension
2. Log into the NMM web portal
3. Click Cookie-Editor > Export > **"Header String"**
4. In PowerShell:

```powershell
Set-NMMHiddenApiCookie -CookieString ".AspNetCore.Cookies=abc123;XSRF-TOKEN=xyz789"
```

---

## Available Cmdlets

| Cmdlet | Description |
|--------|-------------|
| `Connect-NMMHiddenApi` | Start listener & open browser for cookie auth |
| `Set-NMMHiddenApiCookie` | Manually set cookies (Cookie-Editor fallback) |
| `Invoke-HiddenApiRequest` | Call internal NMM web portal APIs |

---

## Examples

### List All Accounts

```powershell
$accounts = Invoke-HiddenApiRequest -Method GET -Endpoint "accounts"
$accounts | Format-Table
```

### Get Intune Policies

```powershell
$policies = Invoke-HiddenApiRequest -Method GET -Endpoint "msp/intune/global/policies/baselines"
$policies | ConvertTo-Json -Depth 5
```

### Custom Endpoint

```powershell
# Using relative endpoint
Invoke-HiddenApiRequest -Method GET -Endpoint "your/custom/endpoint"

# Using full URL
Invoke-HiddenApiRequest -Method GET -Uri "https://your-nmm.nerdio.net/api/v1/msp/custom"
```

---

## Troubleshooting

### "Cannot connect to PowerShell"

Make sure you ran `Connect-NMMHiddenApi` in PowerShell **before** clicking the extension button.

### Extension not showing cookies

- Ensure you're on an NMM page (URL should contain `nerdio.net` or `azurewebsites.net`)
- Try refreshing the page after logging in
- Check that the extension has permission for the site

### Port conflict

If port 19847 is in use:

```powershell
Connect-NMMHiddenApi -Port 19850
```

Then update the port in the extension popup before clicking send.

### Cookies expired

Cookies expire when your browser session ends. Run `Connect-NMMHiddenApi` again after logging back in.

### Request fails with 401/403

- Your session may have expired - re-authenticate
- The endpoint may require different permissions
- The endpoint may have changed with an NMM update

---

## Security Considerations

!!! warning "Cookie Security"
    Authentication cookies provide full access to NMM with your account's permissions. Handle them carefully:

    - Never share your cookies
    - Don't log cookies to files
    - Clear cookies when done with sensitive operations

- **Cookies stay local** - The extension only sends to `localhost`
- **Domain-restricted** - Only captures from NMM domains
- **Session-bound** - Cookies expire with your browser session
- **Your permissions** - API calls use your user's access level

---

## Disclaimer

!!! warning "Use at Your Own Risk"
    The Hidden API is **completely unsupported**:

    - Nerdio may change internal APIs at any time
    - No documentation exists for internal endpoints
    - Breaking changes can occur without warning
    - Do not contact Nerdio Support for Hidden API issues
    - Test thoroughly before any production use
    - You are responsible for any consequences of using these features
