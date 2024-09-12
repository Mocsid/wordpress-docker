module.exports = async function placeOrder(page) {
    // Wait for the "Place Order" button to be visible
    await page.waitForSelector('.wc-block-components-checkout-place-order-button');

    // Click the "Place Order" button
    await page.click('.wc-block-components-checkout-place-order-button');

    console.log('Order placed successfully');
};
