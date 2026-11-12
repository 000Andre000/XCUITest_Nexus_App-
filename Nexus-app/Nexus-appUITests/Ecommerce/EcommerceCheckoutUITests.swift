import XCTest

/// PRD 3.3: Checkout, payment, confirmation, receipt, order history, LOC-5.
final class EcommerceCheckoutUITests: EcommerceUITestCase {

    func testCheckoutScreenShowsAddressSummaryAndPaymentOptions() {
        addHeadphonesToCart()
        goToCheckout()
        assertVisible(["Delivery Address", "Order Summary", "Free shipping applied!", "Payment"])
        XCTAssertTrue(button("Use current location for delivery").exists)
        XCTAssertTrue(button("Pay with Apple Pay").exists)
        XCTAssertTrue(button("Pay with card").exists)
    }

    func testUseCurrentLocationFillsAddress() {
        addHeadphonesToCart()
        goToCheckout()
        tap(button("Use current location for delivery"))
        allowLocationIfPrompted()
        // City is GPS-driven, so only assert the field becomes non-empty.
        let city = field("City")
        waitFor(city)
        let filled = NSPredicate(format: "value != '' AND value != 'City'")
        expectation(for: filled, evaluatedWith: city)
        waitForExpectations(timeout: timeout)
    }

    func testPayWithCardShowsConfirmationAndReceipt() {
        placeOrderWithCard()
        XCTAssertTrue(text("Paid via Card").exists)
        let orderNumber = app.staticTexts.matching(NSPredicate(format: "label MATCHES 'Order #[0-9A-Fa-f]{8}'")).firstMatch
        waitFor(orderNumber)
        assertVisible(["Delivery to"])
        tap(button("Download receipt as PDF"))
        closeShareSheet()
    }

    func testOrderHistoryEmptyStateThenOrderListed() {
        tapTab("Orders")
        waitFor(text("No orders yet"))
        tapTab("Shop")
        placeOrderWithCard()
        tapTab("Orders")
        let order = labelBeginsWith(.button, "Order, ")
        tap(order)
        waitFor(app.navigationBars["Receipt"])
        XCTAssertTrue(button("Download receipt as PDF").exists)
    }
}
