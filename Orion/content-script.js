// Listen for messages from the extension popup
browser.runtime.onMessage.addListener(function(request, sender, sendResponse) {
  if (request.command === "getTopSites") {
    // Call the getTopSites() function and send the result back to the extension popup
    getTopSites().then(sendResponse);
  }
});

function getTopSites() {
  // Use the browser API to get the top sites
  return browser.topSites.get({limit: 10});
}
