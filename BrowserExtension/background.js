// NMM-PS Cookie Helper - Background Service Worker
// Automatically sends cookies when PowerShell listener is active and user is on the correct NMM domain

const DEFAULT_PORT = 19847;
const CHECK_INTERVAL = 2000; // Check every 2 seconds when on potential NMM pages
const SUPPORTED_PATTERNS = ['nerdio.net', 'azurewebsites.net'];

// Track state
let lastSentDomain = null;
let lastSentTime = 0;
const COOLDOWN_MS = 5000; // Don't re-send within 5 seconds

// Listen for tab updates
chrome.tabs.onUpdated.addListener(async (tabId, changeInfo, tab) => {
  // Only trigger on complete page loads
  if (changeInfo.status !== 'complete') return;
  if (!tab.url) return;

  // Check if URL matches potential NMM patterns
  const url = new URL(tab.url);
  const isNMMPage = SUPPORTED_PATTERNS.some(pattern => url.hostname.includes(pattern));

  if (!isNMMPage) return;

  // Check if PowerShell listener is active
  await checkAndSendCookies(tab);
});

// Also check when tab becomes active
chrome.tabs.onActivated.addListener(async (activeInfo) => {
  const tab = await chrome.tabs.get(activeInfo.tabId);
  if (!tab.url) return;

  try {
    const url = new URL(tab.url);
    const isNMMPage = SUPPORTED_PATTERNS.some(pattern => url.hostname.includes(pattern));
    if (isNMMPage) {
      await checkAndSendCookies(tab);
    }
  } catch (e) {
    // Invalid URL, ignore
  }
});

async function checkAndSendCookies(tab) {
  try {
    const url = new URL(tab.url);
    const currentDomain = url.hostname;

    // Get saved port or use default
    const saved = await chrome.storage.local.get(['port']);
    const port = saved.port || DEFAULT_PORT;

    // Check if PowerShell listener is active
    const statusUrl = `http://localhost:${port}/status`;

    let status;
    try {
      const response = await fetch(statusUrl, {
        method: 'GET',
        headers: { 'Accept': 'application/json' }
      });

      if (!response.ok) return;
      status = await response.json();
    } catch (e) {
      // Listener not running, silently return
      return;
    }

    if (!status.listening) return;

    // Check if current domain matches expected domain
    const expectedDomain = status.domain;
    if (!currentDomain.includes(expectedDomain) && !expectedDomain.includes(currentDomain)) {
      // Domain doesn't match - could be on wrong NMM instance
      console.log(`NMM-PS: Domain mismatch. Expected: ${expectedDomain}, Current: ${currentDomain}`);
      return;
    }

    // Cooldown check - don't spam cookies
    const now = Date.now();
    if (currentDomain === lastSentDomain && (now - lastSentTime) < COOLDOWN_MS) {
      return;
    }

    // Get all cookies for this domain
    const cookies = await getCookiesForDomain(url);

    if (cookies.length === 0) {
      console.log('NMM-PS: No cookies found for domain');
      return;
    }

    // Format cookies as header string
    const cookieString = cookies.map(c => `${c.name}=${c.value}`).join('; ');

    // Send cookies to PowerShell
    const cookiesUrl = `http://localhost:${port}/cookies`;
    const postResponse = await fetch(cookiesUrl, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        cookies: cookieString,
        domain: currentDomain,
        timestamp: new Date().toISOString(),
        autoSent: true
      })
    });

    if (postResponse.ok) {
      lastSentDomain = currentDomain;
      lastSentTime = now;

      // Show notification badge
      chrome.action.setBadgeText({ text: '✓', tabId: tab.id });
      chrome.action.setBadgeBackgroundColor({ color: '#00c853' });

      // Clear badge after 3 seconds
      setTimeout(() => {
        chrome.action.setBadgeText({ text: '', tabId: tab.id });
      }, 3000);

      console.log(`NMM-PS: Auto-sent ${cookies.length} cookies to PowerShell`);
    }
  } catch (e) {
    console.error('NMM-PS: Error in checkAndSendCookies:', e);
  }
}

async function getCookiesForDomain(url) {
  try {
    const domain = url.hostname;
    const allCookies = await chrome.cookies.getAll({ domain: domain });

    // Also try parent domain
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
    console.error('NMM-PS: Failed to get cookies:', e);
    return [];
  }
}

// Listen for messages from popup
chrome.runtime.onMessage.addListener((message, sender, sendResponse) => {
  if (message.type === 'checkStatus') {
    checkListenerStatus(message.port).then(sendResponse);
    return true; // Keep channel open for async response
  }
});

async function checkListenerStatus(port) {
  try {
    const response = await fetch(`http://localhost:${port}/status`, {
      method: 'GET',
      headers: { 'Accept': 'application/json' }
    });

    if (response.ok) {
      return await response.json();
    }
    return { listening: false };
  } catch (e) {
    return { listening: false };
  }
}
