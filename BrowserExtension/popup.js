// NMM-PS Cookie Helper - Popup Script

const DEFAULT_PORT = 19847;
const SUPPORTED_DOMAINS = ['nerdio.net', 'azurewebsites.net'];

// DOM Elements
const statusDot = document.getElementById('statusDot');
const currentDomain = document.getElementById('currentDomain');
const sendBtn = document.getElementById('sendBtn');
const btnText = document.getElementById('btnText');
const spinner = document.getElementById('spinner');
const copyBtn = document.getElementById('copyBtn');
const message = document.getElementById('message');
const portInput = document.getElementById('portInput');
const listenerStatus = document.getElementById('listenerStatus');

// State
let currentTab = null;
let cookies = [];
let listenerInfo = null;

// Initialize popup
document.addEventListener('DOMContentLoaded', async () => {
  // Load saved port
  const saved = await chrome.storage.local.get(['port']);
  if (saved.port) {
    portInput.value = saved.port;
  }

  // Get current tab
  const [tab] = await chrome.tabs.query({ active: true, currentWindow: true });
  currentTab = tab;

  if (!tab?.url) {
    showNotSupported('No active tab');
    return;
  }

  try {
    const url = new URL(tab.url);
    const domain = url.hostname;
    currentDomain.textContent = domain;

    // Check if supported domain pattern
    const isSupported = SUPPORTED_DOMAINS.some(d => domain.includes(d));

    if (isSupported) {
      statusDot.classList.add('connected');

      // Pre-fetch cookies
      cookies = await getCookiesForDomain(url);

      // Check if PowerShell listener is active
      await checkListenerStatus();

      if (listenerInfo && listenerInfo.listening) {
        // Check domain match
        const expectedDomain = listenerInfo.domain;
        const domainMatches = domain.includes(expectedDomain) || expectedDomain.includes(domain);

        if (domainMatches) {
          btnText.textContent = `Send ${cookies.length} Cookies`;
          sendBtn.disabled = false;
          showMessage('PowerShell is listening. Auto-send enabled!', 'success');
        } else {
          btnText.textContent = `Send ${cookies.length} Cookies`;
          sendBtn.disabled = false;
          showMessage(`Domain mismatch: expected ${expectedDomain}`, 'error');
        }
      } else {
        btnText.textContent = `Send ${cookies.length} Cookies`;
        sendBtn.disabled = false;
      }
    } else {
      showNotSupported('Not an NMM page');
    }
  } catch (e) {
    showNotSupported('Invalid URL');
  }
});

// Check PowerShell listener status
async function checkListenerStatus() {
  const port = parseInt(portInput.value) || DEFAULT_PORT;

  try {
    const response = await fetch(`http://localhost:${port}/status`, {
      method: 'GET',
      headers: { 'Accept': 'application/json' }
    });

    if (response.ok) {
      listenerInfo = await response.json();
      updateListenerUI(true);
    } else {
      listenerInfo = null;
      updateListenerUI(false);
    }
  } catch (e) {
    listenerInfo = null;
    updateListenerUI(false);
  }
}

// Update listener status UI
function updateListenerUI(isListening) {
  if (!listenerStatus) return;

  if (isListening && listenerInfo) {
    listenerStatus.innerHTML = `
      <span class="listener-dot listening"></span>
      <span>PowerShell listening for <strong>${listenerInfo.domain}</strong></span>
    `;
    listenerStatus.className = 'listener-status listening';
  } else {
    listenerStatus.innerHTML = `
      <span class="listener-dot"></span>
      <span>PowerShell not listening</span>
    `;
    listenerStatus.className = 'listener-status';
  }
}

// Save port on change
portInput.addEventListener('change', async () => {
  await chrome.storage.local.set({ port: parseInt(portInput.value) });
});

// Send cookies button
sendBtn.addEventListener('click', async () => {
  if (cookies.length === 0) {
    showMessage('No cookies found', 'error');
    return;
  }

  setLoading(true);

  const port = parseInt(portInput.value) || DEFAULT_PORT;
  const cookieString = formatCookiesAsHeaderString(cookies);

  try {
    const response = await fetch(`http://localhost:${port}/cookies`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        cookies: cookieString,
        domain: new URL(currentTab.url).hostname,
        timestamp: new Date().toISOString()
      })
    });

    if (response.ok) {
      const result = await response.json();
      showMessage(`Sent ${cookies.length} cookies to PowerShell`, 'success');
      btnText.textContent = 'Cookies Sent!';
      sendBtn.disabled = true;
    } else {
      throw new Error(`HTTP ${response.status}`);
    }
  } catch (error) {
    if (error.message.includes('Failed to fetch')) {
      showMessage(
        `Cannot connect to PowerShell on port ${port}. Run Connect-NMMHiddenApi first.`,
        'error'
      );
    } else {
      showMessage(`Error: ${error.message}`, 'error');
    }
  } finally {
    setLoading(false);
  }
});

// Copy button
copyBtn.addEventListener('click', async () => {
  if (cookies.length === 0) {
    // Try to get cookies if not already fetched
    if (currentTab?.url) {
      cookies = await getCookiesForDomain(new URL(currentTab.url));
    }
  }

  if (cookies.length === 0) {
    showMessage('No cookies found', 'error');
    return;
  }

  const cookieString = formatCookiesAsHeaderString(cookies);

  try {
    await navigator.clipboard.writeText(cookieString);
    showMessage(`Copied ${cookies.length} cookies to clipboard`, 'success');
    copyBtn.textContent = 'Copied!';
    setTimeout(() => {
      copyBtn.textContent = 'Copy as Header String';
    }, 2000);
  } catch (e) {
    showMessage('Failed to copy to clipboard', 'error');
  }
});

// Helper: Get all cookies for a domain (including HttpOnly)
async function getCookiesForDomain(url) {
  try {
    // Get cookies for the exact domain and parent domains
    const domain = url.hostname;
    const allCookies = await chrome.cookies.getAll({ domain: domain });

    // Also try to get cookies for parent domain (e.g., .nerdio.net)
    const parts = domain.split('.');
    if (parts.length > 2) {
      const parentDomain = parts.slice(-2).join('.');
      const parentCookies = await chrome.cookies.getAll({ domain: parentDomain });

      // Merge, avoiding duplicates
      const cookieMap = new Map();
      [...allCookies, ...parentCookies].forEach(c => {
        cookieMap.set(c.name, c);
      });
      return Array.from(cookieMap.values());
    }

    return allCookies;
  } catch (e) {
    console.error('Failed to get cookies:', e);
    return [];
  }
}

// Helper: Format cookies as header string
function formatCookiesAsHeaderString(cookies) {
  return cookies
    .map(c => `${c.name}=${c.value}`)
    .join('; ');
}

// Helper: Show not supported state
function showNotSupported(reason) {
  currentDomain.textContent = reason;
  statusDot.classList.add('error');
  sendBtn.disabled = true;
  btnText.textContent = 'Not on NMM Page';
}

// Helper: Show message
function showMessage(text, type) {
  message.textContent = text;
  message.className = `message ${type}`;
}

// Helper: Set loading state
function setLoading(loading) {
  spinner.style.display = loading ? 'block' : 'none';
  btnText.style.display = loading ? 'none' : 'block';
  sendBtn.disabled = loading;
}
