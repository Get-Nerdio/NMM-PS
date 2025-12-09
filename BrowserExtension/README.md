# NMM-PS Browser Extension

A companion browser extension for the NMM-PS PowerShell module that enables seamless authentication to NMM's internal APIs.

## Installation

### Chrome / Edge / Brave

1. Open your browser and navigate to the extensions page:
   - **Chrome**: `chrome://extensions`
   - **Edge**: `edge://extensions`
   - **Brave**: `brave://extensions`

2. Enable **Developer mode** (toggle in the top-right corner)

3. Click **Load unpacked**

4. Select the `BrowserExtension` folder from this repository

5. The extension icon should appear in your browser toolbar

## Usage

### With PowerShell Listener (Recommended)

1. In PowerShell, run:
   ```powershell
   Import-Module ./NMM-PS.psm1
   Connect-NMMHiddenApi
   ```

2. This will:
   - Start a local HTTP listener on port 19847
   - Open your NMM portal in the browser

3. Log into NMM in the browser

4. Click the **NMM-PS** extension icon in your toolbar

5. Click **"Send Cookies to PowerShell"**

6. The PowerShell function will receive the cookies and complete

7. You can now use `Invoke-HiddenApiRequest` to call internal APIs

### Manual Cookie Copy

If you prefer not to use the HTTP listener:

1. Log into NMM in your browser

2. Click the extension icon

3. Click **"Copy as Header String"**

4. In PowerShell:
   ```powershell
   Set-NMMHiddenApiCookie -CookieString "<paste here>"
   ```

## Features

- **Automatic cookie capture**: Gets all cookies including HttpOnly ones that JavaScript can't access
- **One-click send**: Sends cookies directly to PowerShell listener
- **Copy option**: Manual clipboard copy as backup
- **Domain validation**: Only works on NMM domains (*.nerdio.net, *.azurewebsites.net)
- **Configurable port**: Change the listener port if needed

## Troubleshooting

### "Cannot connect to PowerShell"

Make sure you ran `Connect-NMMHiddenApi` in PowerShell before clicking the extension button.

### Extension not showing cookies

- Make sure you're on an NMM page (the URL should contain `nerdio.net` or `azurewebsites.net`)
- Try refreshing the page after logging in

### Port conflict

If port 19847 is in use, specify a different port:

```powershell
Connect-NMMHiddenApi -Port 19850
```

Then update the port in the extension popup before clicking send.

### Cookies expired

Cookies expire when your browser session ends. Run `Connect-NMMHiddenApi` again after logging back in.

## Security Notes

- The extension only sends cookies to `localhost` - your credentials never leave your machine
- Cookies are only captured from NMM domains
- The HTTP listener only accepts connections from localhost

## Files

```
BrowserExtension/
├── manifest.json    # Extension manifest (Manifest V3)
├── popup.html       # Extension popup UI
├── popup.js         # Popup logic
├── icons/           # Extension icons
│   ├── icon16.png
│   ├── icon48.png
│   └── icon128.png
└── README.md        # This file
```
