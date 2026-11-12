import XCTest

/// BFSI peer-to-peer transfer: validation, confirmation, success and insufficient funds.
final class BFSITransferUITests: BFSIUITestCase {

    private func fillTransfer(amount: String, recipient: String = "jane@example.com") {
        tapTab("Transfer")
        waitFor(text("From Account"))
        selectAccount(picker: "Select an account", name: "Everyday Checking")
        enter(recipient, into: field("Recipient"))
        enter(amount, into: field("Transfer amount"))
        dismissKeyboardVia(field("Recipient"))
    }

    func testSourcePickerExcludesCreditCard() {
        tapTab("Transfer")
        tap(button("Select an account"))
        waitFor(accountOption("Everyday Checking"))
        waitFor(accountOption("Savings"))
        waitFor(accountOption("Investment"))
        XCTAssertFalse(accountOption("Credit Card").exists)
    }

    func testReviewTransferDisabledUntilFormComplete() {
        tapTab("Transfer")
        XCTAssertFalse(button("Review Transfer").isEnabled)
    }

    func testSuccessfulTransferConfirmsAndResetsForm() {
        fillTransfer(amount: "10")
        tap(button("Review Transfer"))
        waitFor(app.alerts["Confirm Transfer"])
        tap(app.alerts.buttons["Send"])
        waitFor(app.alerts["Transfer Sent!"])
        tap(app.alerts.buttons["Done"])
        waitFor(button("Select an account"))
    }

    func testTransferCanBeCancelledAtConfirmation() {
        fillTransfer(amount: "10")
        tap(button("Review Transfer"))
        waitFor(app.alerts["Confirm Transfer"])
        tap(app.alerts.buttons["Cancel"])
        XCTAssertFalse(app.alerts["Transfer Sent!"].exists)
    }

    func testTransferOverBalanceFailsWithInsufficientFunds() {
        fillTransfer(amount: "999999")
        tap(button("Review Transfer"))
        tap(app.alerts.buttons["Send"])
        let failed = waitFor(app.alerts["Transfer Failed"])
        XCTAssertTrue(failed.staticTexts["Insufficient funds or invalid account. Please check your balance and try again."].exists)
        tap(app.alerts.buttons["OK"])
    }
}
