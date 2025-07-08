import XCTest

class BaseUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI-Testing"]
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    // MARK: - Helper Methods
    
    func waitForElement(_ element: XCUIElement, timeout: TimeInterval = 5) {
        let exists = element.waitForExistence(timeout: timeout)
        XCTAssertTrue(exists, "Element should exist")
    }
    
    func tapButton(withIdentifier identifier: String) {
        let button = app.buttons[identifier]
        waitForElement(button)
        button.tap()
    }
    
    func enterText(_ text: String, inField identifier: String) {
        let textField = app.textFields[identifier]
        waitForElement(textField)
        textField.tap()
        textField.typeText(text)
    }
    
    func verifyText(_ text: String, inElement identifier: String) {
        let element = app.staticTexts[identifier]
        waitForElement(element)
        XCTAssertEqual(element.label, text)
    }
    
    func verifyElementExists(_ identifier: String, timeout: TimeInterval = 5) {
        let element = app.otherElements[identifier]
        XCTAssertTrue(element.waitForExistence(timeout: timeout))
    }
    
    func scrollTo(element identifier: String, in scrollView: XCUIElement) {
        let element = app.otherElements[identifier]
        while !element.exists {
            scrollView.swipeUp()
        }
        XCTAssertTrue(element.exists)
    }
} 