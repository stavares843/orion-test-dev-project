import UIKit
import WebKit

class ExtensionOutputController: UIViewController, WKNavigationDelegate {
    
    var webView: WKWebView!
    var fileURL: URL?
    
    init(extensionFileURL: URL) {
        super.init(nibName: nil, bundle: nil)
        fileURL = extensionFileURL.appendingPathComponent("index.html")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create a web view
        webView = WKWebView(frame: view.bounds)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.navigationDelegate = self
        
        // Add the web view to the view hierarchy
        view.addSubview(webView)
        
        // Load the extension output in the web view
        if let url = fileURL {
            webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // Set the title of the view controller to the title of the web page
        title = webView.title
    }
    
}
