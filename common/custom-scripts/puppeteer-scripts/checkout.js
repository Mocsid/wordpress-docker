const puppeteer = require('puppeteer');

module.exports = async function checkout(page) {
  // Click the "Proceed to Checkout" button
  await page.click('.checkout-button');  // Adjust the selector to match your theme
  
  // Wait for the checkout page to load
  await page.waitForSelector('#billing_first_name');
  
  // Fill in the billing details
  await page.type('#billing-first_name', 'John');
  await page.type('#billing-last_name', 'Doe');
  await page.type('#billing-email', 'john@example.com');
  await page.type('#billing-address_1', '123 Test St');
  await page.type('#billing-city', 'Test City');
  await page.type('#billing-postcode', '12345');
  await page.type('#billing-phone', '1234567890');

  // Submit the order
  await page.click('#place_order');
  
  // Wait for a confirmation message or redirect
  await page.waitForNavigation({ waitUntil: 'networkidle2' });
};
