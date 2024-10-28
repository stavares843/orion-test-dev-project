# orion-test-dev-project



This project is built using Swift, with zero Storyboard, using UI elements programmatically using UIKit classes.

Docs generated with Jazzy. You can run `open docs/index.html` in the terminal to display the docs in the browser.

Swiftlint added in build phases.


https://user-images.githubusercontent.com/29093946/228093990-c50815b2-0d1b-49ed-8999-bbb2c709789c.mov


# 
The app does the following:

- Opens a web view in a specified URL, using a Firefox desktop user agent, where the browser pretends is loading the website in a Firefox desktop
- Does a JavaScript injection to change the text in the button in the above URL
- When clicking on the above button, it downloads the topSites extension and ''installs'' (mock implementation) in the Firefox extension folder
- When clicking on the button, it displays a list of 10 URL's - this is a mock implementation, not the real API from topSites API


<img width="486" alt="Captura de ecrã 2023-03-28, às 01 10 37" src="https://user-images.githubusercontent.com/29093946/228094133-255bf398-79f3-4217-8e96-ac86c8bb4c6a.png">



<details>
<summary>BrowserViewController class</summary>

# Description

BrowserViewController class which inherits from UIViewController and has multiple protocols conformance. The class provides a basic implementation of a web browser view controller. The user can input the website URL in the URL bar, and the web page will load accordingly.

# Properties

webView (type: WKWebView)
urlTextField (type: UITextField)
backButton (type: UIBarButtonItem)
firefoxExtensionURL (type: URL)

# Methods

viewDidLoad()
userContentController(_:didReceive:)
installExtension(from:)
goBack()
newTab()
textFieldShouldReturn(_:)
webView(\_:decidePolicyFor:decisionHandler:)

# Observers
None.

# Usage
The BrowserViewController class can be part of a larger iOS application. Depending on the application's requirements, it can be instantiated and presented modally or pushed onto a navigation stack. Once presented, the user can use the browser to navigate the web.
</details>

<details>
<summary>TopSitesViewController class</summary>

# Description
Displays a list of top sites using a WKWebView. The class inherits from UIViewController and conforms to the WKNavigationDelegate protocol.

# Properties
webView
fileURL

# Initialization
init(extensionFileURL: URL)

# View Lifecycle
viewDidLoad()

# Private Methods
setupWebView()
loadExtensionOutput()
getTopSites()

# Deinitialization
deinit()

# Usage
To use this view controller, you can create an instance of it with the file URL to be loaded and present it modally or push it onto a navigation stack. Once presented, it will display the top sites list in the WKWebView.
</details>
