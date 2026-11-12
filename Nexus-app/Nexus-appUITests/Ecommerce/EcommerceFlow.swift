import XCTest

/// E-commerce (ShopNexus) shared steps.
class EcommerceUITestCase: NexusUITestCase {

    override func setUpWithError() throws {
        try super.setUpWithError()
        login(domain: .ecommerce)
        waitFor(text("Hello, Test"))
    }

    func addHeadphonesToCart() {
        tap(button("Wireless Headphones, $79.99"))
        tap(button("Add to cart"))
        waitFor(button("Added to cart"))
    }

    func goToCheckout() {
        tapTab("Cart")
        tap(button("Proceed to checkout"))
        waitFor(text("Delivery Address"))
    }

    func fillManualAddress() {
        let street = field("Street address")
        enter(NexusData.street, into: street)
        enter(NexusData.city, into: field("City"))
        enter(NexusData.zip, into: field("ZIP code"))
        // The ZIP keypad has no return key: refocus street and dismiss with Return.
        tap(street)
        tap(app.keyboards.buttons["Return"])
    }

    func placeOrderWithCard() {
        addHeadphonesToCart()
        goToCheckout()
        fillManualAddress()
        tap(button("Pay with card"))
        waitFor(text("Order Placed!"))
    }
}
