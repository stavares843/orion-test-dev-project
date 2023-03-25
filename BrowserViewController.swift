import UIKit
import WebKit
import SafariServices

class BrowserViewController: UIViewController, WKNavigationDelegate, UITextFieldDelegate, WKUIDelegate {

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

        // Add the web view constraints
        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.topAnchor.constraint(equalTo: view.topAnchor, constant: 40),
            webView.bottomAnchor.constraint(equalTo: toolbar.topAnchor)
        ])
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

    // MARK: - Navigation

    @objc private func goBack() {
        if webView.canGoBack {
            webView.goBack()
        }
    }

    @objc private func newTab() {
        let newViewController = BrowserViewController()
        navigationController?.pushViewController(newViewController, animated: true)
    }

    // MARK: - URL Text Field

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
