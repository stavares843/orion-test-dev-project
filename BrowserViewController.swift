import UIKit
import WebKit
import SafariServices
import SSZipArchive
import Alamofire
import SwiftyXMLParser
import SSZipArchive

    
class BrowserViewController: UIViewController, WKNavigationDelegate, UITextFieldDelegate, WKUIDelegate, WKScriptMessageHandler {

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard message.name == "installExtension" else {
            return
        }
        
        guard let extensionURLString = message.body as? String,
              let extensionURL = URL(string: extensionURLString) else {
            print("Error: Invalid extension URL")
            return
        }
        
        installExtension(from: extensionURL)
    }

    struct Manifest: Codable {
           let name: String
           let version: String
           let description: String
       }

    
    var webView: WKWebView!
    var urlTextField: UITextField!
    var backButton: UIBarButtonItem!

    // Define the URL of the Firefox extension
    let firefoxExtensionURL = URL(string: "https://addons.mozilla.org/firefox/downloads/latest/top-sites-button/addon-483724-latest.xpi")!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Create a WKWebView instance
        webView = WKWebView(frame: view.bounds)

        // Set the custom user agent string to make the website believe that the request is coming from a desktop version of Firefox
        webView.customUserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:89.0) Gecko/20100101 Firefox/89.0"

        // Set the navigation delegate to self
        webView.navigationDelegate = self

        // Add the web view to the view controller's view
        view.addSubview(webView)

        // Load the website
        let url = URL(string: "https://addons.mozilla.org/en-US/firefox/addon/top-sites-button/")!
        let request = URLRequest(url: url)
        webView.load(request)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            
            let javascript = """
                document.querySelector('.Button--action').addEventListener('click', function() {
                    webkit.messageHandlers.installExtension.postMessage("https://addons.mozilla.org/firefox/downloads/latest/top-sites-button/addon-1865-latest.xpi");
                });
                document.querySelector('.Button--action').textContent = '+ Add to Orion';
            """
            self.webView.evaluateJavaScript(javascript) { (_, error) in
                if let error = error {
                    print("Error evaluating JavaScript: \(error.localizedDescription)")
                } else {
                    print("JavaScript executed successfully")
                    
                    // Add code to download and install the extension when the button is tapped
                    let userScript = WKUserScript(source: "window.webkit.messageHandlers.installExtensionButton = { postMessage: function(url) { window.location.href = url; } }", injectionTime: .atDocumentStart, forMainFrameOnly: true)
                    self.webView.configuration.userContentController.addUserScript(userScript)
                    self.webView.configuration.userContentController.add(self, name: "installExtension")
                }
            }
        }
        
        //Create the URL bar
        let toolbar = UIToolbar()
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toolbar)

        let backButton = UIBarButtonItem(title: "<", style: .plain, target: self, action: #selector(goBack))
        self.backButton = backButton

        let urlTextField = UITextField()
        urlTextField.translatesAutoresizingMaskIntoConstraints = false
        urlTextField.borderStyle = .roundedRect
        urlTextField.delegate = self
        self.urlTextField = urlTextField

        let urlBar = UIBarButtonItem(customView: urlTextField)
        toolbar.items = [backButton, UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), urlBar]

      //  let installButton = UIBarButtonItem(title: "Install Extension", style: .plain, target: self, action: #selector(installExtension))
      //  navigationItem.rightBarButtonItem = installButton

        // Add the toolbar to the bottom of the view
        NSLayoutConstraint.activate([
            toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            toolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])

        // Create the "+" button for new tabs
        let newTabButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(newTab))

        // Add a flexible spacer between the "+" button and the URL bar
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

        // Add the new tab button and the spacer to the right side of the toolbar
        toolbar.items?.append(contentsOf: [spacer, newTabButton])

        // Increase the width of the URL text field
        urlTextField.widthAnchor.constraint(equalToConstant: 350).isActive = true


        // Add the web view constraints
        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.topAnchor.constraint(equalTo: view.topAnchor, constant: 40),
            webView.bottomAnchor.constraint(equalTo: toolbar.topAnchor)
        ])
    }
        
        @objc private func installExtension(from fileURL: URL) {
            let task = URLSession.shared.downloadTask(with: fileURL) { (url, response, error) in
                if let error = error {
                    print("Error downloading file: \(error.localizedDescription)")
                    return
                }
                
                guard let downloadURL = url else {
                    print("Error: No URL returned for downloaded file")
                    return
                }
                
                print("Downloaded file to: \(downloadURL)")
                
                let fileManager = FileManager.default
                let extensionsDirURL = fileManager.urls(for: .libraryDirectory, in: .userDomainMask)[0].appendingPathComponent("Application Support/Firefox/Extensions", isDirectory: true)
                
                do {
                    try fileManager.createDirectory(at: extensionsDirURL, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    print("Error creating extensions directory: \(error.localizedDescription)")
                    return
                }
                
                let destFilePath = extensionsDirURL.appendingPathComponent(downloadURL.lastPathComponent)
                
                do {
                    try fileManager.moveItem(at: downloadURL, to: destFilePath)
                    print("Installed extension to: \(destFilePath)")
                } catch {
                    print("Error installing extension: \(error.localizedDescription)")
                }
            }
            
            task.resume()
        }

    @objc private func newTab() {
        // Create a new tab
        let newTab = BrowserViewController()
        navigationController?.pushViewController(newTab, animated: true)
    }

    @objc private func goBack() {
        // Go back to the previous page
        if webView.canGoBack {
            webView.goBack()
        }
    }

    // MARK: - WKNavigationDelegate

    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        // Update the URL text field when the page starts loading
        urlTextField.text = webView.url?.absoluteString
    }

    // MARK: - UITextFieldDelegate

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Load the requested URL when the user presses Enter
        if let text = textField.text, let url = URL(string: text) {
            webView.load(URLRequest(url: url))
            textField.resignFirstResponder()
        }
        return true
    }
}
