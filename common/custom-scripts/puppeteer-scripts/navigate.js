const puppeteer = require('puppeteer');

module.exports = async function navigate(page) {
    // Navigate to the WooCommerce site running on Docker IP and port
    await page.goto('http://172.30.174.96:8081', {  // Use the correct IP and port
        waitUntil: 'networkidle2',  // Wait until all resources have loaded
    });
};
