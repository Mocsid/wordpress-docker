module.exports = async function addToCart(page) {
  // Step 1: Wait for the "Add to Cart" button to be visible
  await page.waitForSelector('a.add_to_cart_button', { visible: true });

  // Step 2: Click the "Add to Cart" button
  await page.click('a.add_to_cart_button');

  // Step 3: Wait for some time to ensure the product is added (using setTimeout)
  await new Promise(resolve => setTimeout(resolve, 3000));  // Wait for 3 seconds
};
