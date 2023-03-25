import UIKit
import WebKit
import SafariServices

class BrowserViewController: UIViewController, WKNavigationDelegate, UITextFieldDelegate {

    var webView: WKWebView!
    var urlTextField: UITextField!
    var backButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Create the URL bar
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
        
        let installButton = UIBarButtonItem(title: "Install Extension", style: .plain, target: self, action: #selector(installExtension))
        navigationItem.rightBarButtonItem = installButton
        
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
          
        // Create the web view
        let webView = WKWebView()
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = self
        view.addSubview(webView)
        self.webView = webView
        
        // Add constraints
        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.topAnchor.constraint(equalTo: view.topAnchor, constant: 40),
            webView.bottomAnchor.constraint(equalTo: toolbar.topAnchor)
        ])
        
        // Load the initial URL
  

        let initialUrl = URL(string: "https://addons.mozilla.org/en-US/firefox/addon/top-sites-button/")!
        webView.load(URLRequest(url: initialUrl))
        
    }
    
    private func addExtension(from url: URL) {
        let extensionController = self.webView.configuration.userContentController
        
        do {
            let extensionScript = try String(contentsOf: url, encoding: .utf8)
            let userScript = WKUserScript(source: extensionScript, injectionTime: .atDocumentStart, forMainFrameOnly: false)
            extensionController.addUserScript(userScript)
            
            print("Extension added successfully")
        } catch {
            print("Error adding extension: \(error.localizedDescription)")
        }
    }
    

    @objc private func installExtension() {
        let urlString = "https://addons.mozilla.org/firefox/downloads/latest/top-sites-button/addon-483724-latest.xpi"
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.downloadTask(with: url) { (url, _, error) in
            if let error = error {
                print("Error downloading extension: \(error.localizedDescription)")
                return
            }
            
            guard let url = url else { return }
            let fileManager = FileManager.default
            let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
            let destinationUrl = documentDirectory.appendingPathComponent(url.lastPathComponent)
            
            do {
                try fileManager.moveItem(at: url, to: destinationUrl)
                print("Extension downloaded and saved to \(destinationUrl.absoluteString)")
            } catch {
                print("Error moving file: \(error.localizedDescription)")
            }
        }.resume()
        
    }
    
    // MARK: - Actions
    
    @objc func goBack() {
        if webView.canGoBack {
            webView.goBack()
        }
    }
    
    @objc func newTab() {
        // Implement new tab functionality here
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        guard let text = textField.text, let url = URL(string: text) else {
            return false
        }
        
        if let firefoxUrlScheme = URL(string: "firefox://open-url?url=\(url.absoluteString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)"), UIApplication.shared.canOpenURL(firefoxUrlScheme) {
            UIApplication.shared.open(firefoxUrlScheme, options: [:], completionHandler: nil)
        } else {
            let safariVC = SFSafariViewController(url: url)
            present(safariVC, animated: true)
        }
        
        return true
    }



    // MARK: - WKNavigationDelegate
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        backButton.isEnabled = webView.canGoBack
        urlTextField.text = webView.url?.absoluteString
    }
}
