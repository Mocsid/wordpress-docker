const puppeteer = require('puppeteer');
const navigate = require('./navigate');  // Navigate to the main WooCommerce site
const goToShop = require('./go-to-shop');  // Go to the /shop page
const addToCart = require('./add-to-cart');  // Add a product to the cart
const goToCheckout = require('./go-to-checkout');  // Navigate to the checkout page
const fillCheckoutForm = require('./fill-checkout-form');  // Fill out the checkout form
const placeOrder = require('./place-order');  // Place the order

(async () => {
    const browser = await puppeteer.launch({
        headless: true,  // Set to false if you want to see the browser in action
        args: [
            '--no-sandbox',
            '--disable-setuid-sandbox',
            '--disable-dev-shm-usage'
        ]
    });

    const page = await browser.newPage();

    try {
        // Step 1: Navigate to the WooCommerce site
        await navigate(page);
        console.log('Main site successful!');

        // Step 2: Go to the shop page
        await goToShop(page);
        console.log('Shop page successful!');

        // Step 3: Add product to cart
        await addToCart(page);
        console.log('Product added to cart successfully');

        // Step 4: Go to checkout page
        await goToCheckout(page);
        console.log('Navigated to checkout successfully');

        // Step 5: Fill out checkout form
        await fillCheckoutForm(page);
        console.log('Checkout form filled successfully');

        // Step 6: Place the order
        await placeOrder(page);
        console.log('Order placed successfully!');

    } catch (error) {
        console.error('Error during order simulation:', error);
    } finally {
        await browser.close();
    }
})();
