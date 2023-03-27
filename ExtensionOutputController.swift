import UIKit
import WebKit

class TopSitesViewController: UIViewController, WKNavigationDelegate {

    // MARK: - Properties
    
    private var webView: WKWebView!
    private var fileURL: URL?

    // MARK: - Initialization
    
    convenience init(extensionFileURL: URL) {
        self.init(nibName: nil, bundle: nil)
        fileURL = extensionFileURL
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupWebView()
        loadExtensionOutput()
    }
    
    deinit {
        webView.removeFromSuperview()
        webView = nil
    }
    
    // MARK: - Private Methods
    
    private func setupWebView() {
        webView = WKWebView(frame: view.bounds)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.navigationDelegate = self
        view.addSubview(webView)
    }
    
    private func loadExtensionOutput() {
        guard let fileURL = fileURL else { return }
        
        webView.loadFileURL(fileURL, allowingReadAccessTo: fileURL.deletingLastPathComponent())
        
        let urls = getTopSites()
        let htmlString = """
            <html>
                <head>
                    <meta name="viewport" content="width=device-width, initial-scale=1">
                    <style>
                        body {
                            font-family: sans-serif;
                            font-size: 16px;
                        }
                        h1 {
                            font-size: 24px;
                            font-weight: bold;
                            margin-top: 20px;
                            margin-bottom: 10px;
                        }
                        ul {
                            margin: 0;
                            padding: 0;
                            list-style-type: none;
                        }
                        li {
                            margin-bottom: 10px;
                        }
                    </style>
                </head>
                <body>
                    <h1>Top Sites</h1>
                    <ul>
                        \(urls.map { "<li><a href=\"\($0)\">\($0)</a></li>" }.joined())
                    </ul>
                </body>
            </html>
            """
        
        DispatchQueue.main.async {
            self.webView.loadHTMLString(htmlString, baseURL: nil)
        }

    }
    
    private func getTopSites() -> [String] {
        return [
            "https://www.google.com",
            "https://www.youtube.com",
            "https://www.facebook.com",
            "https://www.wikipedia.org",
            "https://www.twitter.com",
            "https://www.amazon.com",
            "https://www.reddit.com",
            "https://www.instagram.com",
            "https://www.netflix.com",
            "https://www.linkedin.com"
        ]
    }
}
