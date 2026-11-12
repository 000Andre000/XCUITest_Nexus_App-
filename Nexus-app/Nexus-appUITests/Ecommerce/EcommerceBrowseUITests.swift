import XCTest

/// PRD 3.3: Shop home, categories, product detail, search.
final class EcommerceBrowseUITests: EcommerceUITestCase {

    func testShopHomeShowsGreetingFeaturedAndCity() {
        assertVisible(["Hello, Test", "Featured"])
        XCTAssertTrue(button("Wireless Headphones, $79.99").exists)
        XCTAssertTrue(button("Smart Watch, $149.00").exists)
        // LOC-4: city label and "Deals in {city}" banner are IP-driven, so only assert presence.
        let deals = app.staticTexts.matching(NSPredicate(format: "label BEGINSWITH 'Deals in'")).firstMatch
        waitFor(deals)
    }

    func testCategoryFilterElectronicsHidesOthers() {
        tap(button("Electronics"))
        waitFor(button("Wireless Headphones, $79.99"))
        XCTAssertTrue(button("Smart Watch, $149.00").exists)
        XCTAssertFalse(button("Running Shoes, $64.50").exists)
    }

    func testCategoryFilterSportsAndAccessories() {
        tap(button("Sports"))
        waitFor(button("Running Shoes, $64.50"))
        XCTAssertFalse(button("Smart Watch, $149.00").exists)
        tap(button("Accessories"))
        waitFor(button("Backpack, $39.99"))
        XCTAssertTrue(button("Sunglasses, $24.99").exists)
        tap(button("All"))
        waitFor(button("Wireless Headphones, $79.99"))
    }

    func testProductDetailShowsDescriptionRatingAndPrice() {
        tap(button("Wireless Headphones, $79.99"))
        assertVisible(["$79.99", "Premium over-ear headphones with active noise cancellation."])
        XCTAssertTrue(text("(128)").exists)
        XCTAssertTrue(button("Add to cart").exists)
    }

    func testSearchEmptyStateResultsAndNoResults() {
        tapTab("Search")
        waitFor(text("Search for products"))
        let search = field("Search products")
        enter("Watch", into: search)
        waitFor(button("Smart Watch, $149.00"))
        tap(button("Clear search"))
        enter("zzzzz", into: search)
        waitFor(text("No results for: zzzzz"))
    }
}
