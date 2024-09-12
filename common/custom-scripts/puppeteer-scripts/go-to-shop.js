module.exports = async function goToShop(page) {
  // Step 1: Navigate to the /shop page
  await page.goto('http://172.30.174.96:8081/shop', {
      waitUntil: 'networkidle2',  // Wait until all resources have been loaded
  });

  // Step 2: Wait for the shop page to fully load
  await page.waitForSelector('.products', { visible: true });  // Adjust the selector based on your shop page
};
