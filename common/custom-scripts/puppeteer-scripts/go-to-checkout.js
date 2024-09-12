module.exports = async function goToCheckout(page) {
  await page.goto('http://172.30.174.96:8081/checkout', { waitUntil: 'networkidle2' });

  const firstNameField = await page.evaluate(() => {
      const xpathResult = document.evaluate("//input[@id='billing-first_name']", document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null);
      return xpathResult.singleNodeValue;
  });

  if (!firstNameField) {
      throw new Error('First name field not found');
  }

  await firstNameField.type('John');
};
