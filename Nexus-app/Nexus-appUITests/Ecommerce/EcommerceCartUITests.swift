import XCTest

/// PRD 3.3: Cart line items, quantity, totals (8% tax), empty state.
final class EcommerceCartUITests: EcommerceUITestCase {

    func testEmptyCartState() {
        tapTab("Cart")
        assertVisible(["Your cart is empty", "Add items from the Shop tab"])
    }

    func testAddToCartUpdatesCartAndSummary() {
        addHeadphonesToCart()
        tapTab("Cart")
        assertVisible(["ITEMS", "SUMMARY", "$79.99", "$6.40", "Free", "$86.39"])
        XCTAssertTrue(button("Proceed to checkout").exists)
    }

    func testIncrementAndDecrementQuantityRecalculatesTotals() {
        addHeadphonesToCart()
        tapTab("Cart")
        tap(app.buttons["Increment"])
        assertVisible(["$159.98", "$12.80", "$172.78"])
        tap(app.buttons["Decrement"])
        assertVisible(["$79.99", "$86.39"])
    }

    func testAddingTwoDifferentProductsShowsBothLines() {
        addHeadphonesToCart()
        goBack()
        tap(button("Smart Watch, $149.00"))
        tap(button("Add to cart"))
        waitFor(button("Added to cart"))
        tapTab("Cart")
        XCTAssertTrue(labelBeginsWith(.any, "Wireless Headphones").exists)
        XCTAssertTrue(labelBeginsWith(.any, "Smart Watch").exists)
    }
}
