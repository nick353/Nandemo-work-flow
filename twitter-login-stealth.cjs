const puppeteer = require('puppeteer-extra');
const StealthPlugin = require('puppeteer-extra-plugin-stealth');
puppeteer.use(StealthPlugin());

(async () => {
  console.log('Launching browser with Stealth Plugin...');
  
  const browser = await puppeteer.launch({
    headless: true,
    executablePath: '/usr/bin/chromium',
    args: [
      '--no-sandbox',
      '--disable-setuid-sandbox',
      '--disable-blink-features=AutomationControlled'
    ]
  });
  
  const page = await browser.newPage();
  
  // Set realistic viewport
  await page.setViewport({ width: 1280, height: 800 });
  
  // Set user agent
  await page.setUserAgent('Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36');
  
  console.log('Navigating to Twitter login...');
  await page.goto('https://twitter.com/login', { waitUntil: 'networkidle2', timeout: 30000 });
  
  console.log('Page loaded:', await page.title());
  console.log('Current URL:', page.url());
  
  // Take screenshot
  await page.screenshot({ path: '/root/clawd/twitter-login.png' });
  console.log('Screenshot saved to: /root/clawd/twitter-login.png');
  
  // Check for error messages
  const content = await page.content();
  if (content.includes('Something went wrong')) {
    console.log('❌ Twitter still detecting bot behavior');
  } else if (content.includes('Sign in') || content.includes('Log in')) {
    console.log('✅ Login page loaded successfully!');
  }
  
  await browser.close();
  console.log('Browser closed.');
})();
