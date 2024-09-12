module.exports = async function fillCheckoutForm(page) {
    // Wait for the checkout form to be visible by checking the first billing field
    await page.waitForSelector('#billing-first_name');  // Updated ID based on your form

    // Fill in the billing details
    await page.type('#billing-first_name', 'John');
    await page.type('#billing-last_name', 'Doe');
    await page.type('#billing-email', 'john@example.com');
    await page.type('#billing-address_1', '1234 Elm Street');
    await page.type('#billing-city', 'Springfield');
    await page.type('#billing-postcode', '62701');
    await page.type('#billing-phone', '+1 555-123-4567');

    console.log('Checkout form filled successfully');
};
