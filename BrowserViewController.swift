import UIKit
import WebKit
import SafariServices
import SSZipArchive
import Alamofire
import SwiftyXMLParser

class BrowserViewController: UIViewController, WKNavigationDelegate, UITextFieldDelegate, WKUIDelegate {
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

        // Inject JavaScript to modify the Firefox add-on button
        // Get a reference to the WKWebView instance
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let javascript = """
                document.querySelector('.Button--action').addEventListener('click', function() {
                    webkit.messageHandlers.installExtension.postMessage("");
                });
                document.querySelector('.Button--action').textContent = '+ Add to Orion';
            """
            self.webView.evaluateJavaScript(javascript) { (_, error) in
                if let error = error {
                    print("Error evaluating JavaScript: \(error.localizedDescription)")
                } else {
                    print("JavaScript executed successfully")
                }
            }
        }

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

      //  let installButton = UIBarButtonItem(title: "Install Extension", style: .plain, target: self, action: #selector(installExtension))
      //  navigationItem.rightBarButtonItem = installButton

        // Add the toolbar to the bottom of the view
        NSLayoutConstraint.activate([
            toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            toolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
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
}
    extension BrowserViewController {
        func downloadAndExtractPackage(url: URL) {
            let downloadTask = URLSession.shared.downloadTask(with: url) { location, _, error in
                guard let location = location else {
                    print("Failed to download package: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let destinationUrl = documentsUrl.appendingPathComponent("package.zip")

                do {
                    try FileManager.default.moveItem(at: location, to: destinationUrl)
                    try SSZipArchive.unzipFile(atPath: destinationUrl.path, toDestination: documentsUrl.path)
                    let manifestUrl = documentsUrl.appendingPathComponent("manifest.json")
                    let manifestData = try Data(contentsOf: manifestUrl)
                    let decoder = JSONDecoder()
                    let manifest = try decoder.decode(Manifest.self, from: manifestData)
                    // Do something with the manifest data here
                } catch {
                    print("Failed to extract package: \(error.localizedDescription)")
                }
            }
            downloadTask.resume()
        }

    @objc private func installExtension() {
        // Copy the extension file to the Library directory
        let fileManager = FileManager.default
        let libraryDirectory = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)[0]
        let extensionDirectory = "\(libraryDirectory)/Application Support/Firefox/Profiles/default/extensions"
        let sourceFilePath = Bundle.main.path(forResource: "myextension", ofType: "xpi")!
        let destinationFilePath = "\(extensionDirectory)/myextension.xpi"

        do {
            try fileManager.copyItem(atPath: sourceFilePath, toPath: destinationFilePath)
            print("Extension file copied to Library directory")
        } catch {
            print("Error copying extension file: \(error.localizedDescription)")
            return
        }

        // Move the extension file to the extensions directory
        let destinationDirectory = "\(extensionDirectory)/myextension@mycompany.com"
        do {
            try fileManager.moveItem(atPath: destinationFilePath, toPath: destinationDirectory)
            print("Extension file moved to extensions directory")
        } catch {
            print("Error moving extension file: \(error.localizedDescription)")
            return
        }
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

        func downloadFile(at url: URL, completion: @escaping (Result<URL, Error>) -> Void) {
                let destination = DownloadRequest.suggestedDownloadDestination(for: .cachesDirectory)
                AF.download(url, to: destination)
                    .responseData { response in
                        switch response.result {
                        case .success(let data):
                            let fileName = response.response?.suggestedFilename ?? "file.zip"
                            let fileURL = URL(fileURLWithPath: NSTemporaryDirectory())
                                .appendingPathComponent(UUID().uuidString)
                                .appendingPathComponent(fileName)
                            do {
                                try data.write(to: fileURL)
                                completion(.success(fileURL))
                            } catch {
                                completion(.failure(error))
                            }
                        case .failure(let error):
                            completion(.failure(error))
                        }

                        func extractFile(at zipURL: URL, completion: @escaping (Result<URL, Error>) -> Void) {
                                    let extractPath = URL(fileURLWithPath: NSTemporaryDirectory())
                                        .appendingPathComponent(UUID().uuidString)
                                    do {
                                        try SSZipArchive.unzipFile(
                                            atPath: zipURL.path,
                                            toDestination: extractPath.path,
                                            delegate: nil
                                        )
                                        completion(.success(extractPath))
                                    }
                                }

                        func readManifest(at extractURL: URL, completion: @escaping (Result<XML.Accessor, Error>) -> Void) {
                                    do {
                                        let manifestURL = extractURL.appendingPathComponent("manifest.xml")
                                        let data = try Data(contentsOf: manifestURL)
                                        let xml = XML.parse(data)
                                        completion(.success(xml))
                                    } catch {
                                        completion(.failure(error))
                                    }

                            func downloadAndInstallExtension() {
                                guard let url = URL(string: "https://addons.mozilla.org/firefox/downloads/latest/top-sites-button/latest.xpi") else {
                                    print("Invalid URL")
                                    return
                                }

                                // Download the extension
                                self.downloadFile(at: url) { result in
                                    switch result {
                                    case .success(let zipURL):
                                        print("Extension downloaded to: \(zipURL.path)")

                                        // Extract the extension
                                        extractFile(at: zipURL) { result in
                                            switch result {
                                            case .success(let extractURL):
                                                print("Extension extracted to: \(extractURL.path)")

                                                // Read the extension manifest
                                                readManifest(at: extractURL) { result in
                                                    switch result {
                                                    case .success(let manifest):
                                                        // Check if the extension is compatible with the current browser
                                                        let isCompatible = manifest["em:targetApplication"].all?.first?["em:id"].text == "{ec8030f7-c20a-464f-9b0e-13a3a9e97384}"
                                                        if isCompatible {
                                                            // Copy the extension files to the appropriate directory
                                                            let fileManager = FileManager.default
                                                            let libraryDirectory = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)[0]
                                                            let extensionDirectory = "\(libraryDirectory)/Application Support/Firefox/Profiles/default/extensions"
                                                            let sourceDirectory = extractURL.appendingPathComponent("chrome")
                                                            let destinationDirectory = "\(extensionDirectory)/topsites"
                                                            do {
                                                                try fileManager.createDirectory(atPath: destinationDirectory, withIntermediateDirectories: true, attributes: nil)
                                                                try fileManager.copyItem(atPath: sourceDirectory.path, toPath: destinationDirectory)
                                                                print("Extension installed successfully")
                                                            } catch {
                                                                print("Error installing extension: \(error.localizedDescription)")
                                                            }
                                                        } else {
                                                            print("Extension is not compatible with the current browser")
                                                        }
                                                    case .failure(let error):
                                                        print("Error reading extension manifest: \(error.localizedDescription)")
                                                    }
                                                }

                                            case .failure(let error):
                                                print("Error extracting extension: \(error.localizedDescription)")
                                            }
                                        }

                                    case .failure(let error):
                                        print("Error downloading extension: \(error.localizedDescription)")
                                    }

    // MARK: - UITextFieldDelegate

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Load the requested URL when the user presses Enter
        if let text = textField.text, let url = URL(string: text) {
            self.webView.load(URLRequest(url: url))
            textField.resignFirstResponder()
        }
        return true
        }
    }
}
    }
}
    }
}
