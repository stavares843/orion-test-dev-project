import XCTest

@testable import Orion

class BrowserViewControllerTests: XCTestCase {

    var sut: BrowserViewController!

    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = BrowserViewController()
        sut.loadViewIfNeeded()
    }

    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }

    
    func testWebViewLoadsWebsite() {
        // Given
        let expectedUrl = URL(string: "https://addons.mozilla.org/en-US/firefox/addon/top-sites-button/")!

        // When
        sut.viewDidLoad()

        // Then
        XCTAssertEqual(sut.webView.url, expectedUrl)
    }

    func testWebView_CustomUserAgent() {
            sut.viewDidLoad()
            XCTAssertEqual(sut.webView.customUserAgent, "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:89.0) Gecko/20100101 Firefox/89.0")
        }
    
    func testLoadingURL() {
            // Set the URL text field to a test URL and call the textFieldShouldReturn(_:) method
            sut.urlTextField.text = "https://addons.mozilla.org/en-US/firefox/addon/top-sites-button/"
            let shouldReturn = sut.textFieldShouldReturn(sut.urlTextField)

            // Verify that the web view is loaded with the expected URL
            XCTAssertTrue(shouldReturn)
            XCTAssertEqual(sut.webView.url?.absoluteString, "https://addons.mozilla.org/en-US/firefox/addon/top-sites-button/")
        }
    
    /*func testInstallExtension() { // skip test because extension is not really installed
        // Given
        let extensionUrl = URL(string: "https://addons.mozilla.org/firefox/downloads/latest/top-sites-button/addon-1865-latest.xpi")!
        let expectation = self.expectation(description: "extension downloaded")

        // When
        sut.installExtension(from: extensionUrl)

        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
            let fileManager = FileManager.default
            let extensionsDirURL = fileManager.urls(for: .libraryDirectory, in: .userDomainMask)[0].appendingPathComponent("Extensions")
            let installedExtension = extensionsDirURL.appendingPathComponent("topsitesbutton@mozilla.org.xpi")
            XCTAssertTrue(fileManager.fileExists(atPath: installedExtension.path))
            expectation.fulfill()
        }
        waitForExpectations(timeout: 15.0, handler: nil)*/
    }

