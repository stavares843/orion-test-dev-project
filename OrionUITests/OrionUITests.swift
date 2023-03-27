import XCTest
@testable import Orion

extension XCUIElement {
    func clearAndEnterText(_ text: String) {
        guard let stringValue = self.value as? String else {
            XCTFail("Tried to clear and enter text into a non-string value")
            return
        }
        self.tap()
        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: stringValue.count)
        self.typeText(deleteString)
        self.typeText(text)
    }
}

class BrowserViewControllerTests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    func testClearAndTypeText() {
        let app = XCUIApplication()
        app.launch()
        let textField = XCUIApplication().toolbars["Toolbar"].children(matching: .other).element.children(matching: .other).element.children(matching: .textField).element
                textField.clearAndEnterText("apple.com")
    }
}
