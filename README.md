# orion-test-dev-project



This project is built using Swift, with zero Storyboard, using UI elements programmatically using UIKit classes.

Docs generated with Jazzy available [here](https://github.com/stavares843/orion-test-dev-project/blob/main/docs/index.html)

Linter added as a script in build phases.
Tests running using Github Actions.

<p align="left">
    <a href="https://github.com/stavares843/orion-test-dev-project/actions"><img src="https://github.com/stavares843/orion-test-dev-project/actions/workflows/tests.yml/badge.svg" /></a>
</p>

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
