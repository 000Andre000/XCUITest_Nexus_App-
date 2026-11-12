import XCTest

/// Base class for every Nexus UI test: launches the app and provides shared, wait-based helpers.
class NexusUITestCase: XCTestCase {
    var app: XCUIApplication!
    let timeout: TimeInterval = 15

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    // MARK: - Element shortcuts

    func button(_ label: String) -> XCUIElement { app.buttons[label] }
    func text(_ label: String) -> XCUIElement { app.staticTexts[label] }
    func field(_ label: String) -> XCUIElement { app.textFields[label] }
    func labelBeginsWith(_ type: XCUIElement.ElementType, _ prefix: String) -> XCUIElement {
        app.descendants(matching: type)
            .matching(NSPredicate(format: "label BEGINSWITH %@", prefix)).firstMatch
    }

    // MARK: - Waits / actions

    @discardableResult
    func waitFor(_ element: XCUIElement, file: StaticString = #filePath, line: UInt = #line) -> XCUIElement {
        XCTAssertTrue(element.waitForExistence(timeout: timeout), "Element not found: \(element)", file: file, line: line)
        return element
    }

    func tap(_ element: XCUIElement, file: StaticString = #filePath, line: UInt = #line) {
        waitFor(element, file: file, line: line).tap()
    }

    func enter(_ value: String, into element: XCUIElement, file: StaticString = #filePath, line: UInt = #line) {
        tap(element, file: file, line: line)
        element.typeText(value)
    }

    func assertVisible(_ labels: [String], file: StaticString = #filePath, line: UInt = #line) {
        for label in labels {
            XCTAssertTrue(text(label).waitForExistence(timeout: timeout), "Missing text: \(label)", file: file, line: line)
        }
    }

    func scrollUntilVisible(_ element: XCUIElement, maxSwipes: Int = 6) {
        var swipes = 0
        while !element.isHittable && swipes < maxSwipes {
            app.swipeUp()
            swipes += 1
        }
    }

    func tapTab(_ label: String) {
        tap(app.tabBars.buttons[label])
    }

    func goBack() {
        tap(app.navigationBars.buttons.firstMatch)
    }

    // MARK: - System alerts

    func respondToSystemAlert(button label: String, wait: TimeInterval = 5) {
        let alertButton = XCUIApplication(bundleIdentifier: "com.apple.springboard").alerts.buttons[label]
        if alertButton.waitForExistence(timeout: wait) { alertButton.tap() }
    }

    func allowLocationIfPrompted() {
        respondToSystemAlert(button: "Allow While Using App")
    }

    func closeShareSheet() {
        let close = app.buttons["Close"]
        if close.waitForExistence(timeout: timeout) { close.tap() }
    }
}
