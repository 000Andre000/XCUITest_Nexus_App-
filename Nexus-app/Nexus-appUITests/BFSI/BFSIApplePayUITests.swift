import XCTest

/// BFSI Pay tab: Apple Pay payment and recent payments list.
final class BFSIApplePayUITests: BFSIUITestCase {

    func testPayScreenShowsPaymentDetailsForm() {
        tapTab("Pay")
        assertVisible(["Payment Details"])
        waitFor(button("Select account"))
        waitFor(field("Merchant name"))
        waitFor(field("Payment amount"))
    }

    func testApplePayPaymentCompletesAndIsListed() {
        tapTab("Pay")
        waitFor(text("Payment Details"))
        selectAccount(picker: "Select account", name: "Everyday Checking")
        enter("Coffee Shop", into: field("Merchant name"))
        enter("5", into: field("Payment amount"))
        dismissKeyboardVia(field("Merchant name"))
        tap(button("Buy with Apple Pay"))
        waitFor(app.alerts["Payment"])
        tap(app.alerts.buttons["OK"])
        waitFor(text("Recent Apple Pay"))
        waitFor(text("Coffee Shop"))
        waitFor(text("Completed"))
    }
}
