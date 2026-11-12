import XCTest

/// Travel (TripNexus) shared steps. Login/OTP are identical to the industry login used by E-commerce.
class TravelUITestCase: NexusUITestCase {

    override func setUpWithError() throws {
        try super.setUpWithError()
        login(domain: .travel)
        waitFor(text("Where to next?"))
    }

    func openSearchTab() {
        tapTab("Search")
    }

    /// Flights tab: use the current-location origin, enter a destination and search.
    func searchFlights(to destination: String = "Tokyo") {
        openSearchTab()
        tap(labelBeginsWith(.button, "Use current location"))
        enter(destination, into: field("To"))
        dismissKeyboard()
        tap(button("Search flights"))
    }

    func searchHotels(in destination: String = "Tokyo") {
        openSearchTab()
        tap(app.buttons["Hotels"])
        enter(destination, into: field("Destination"))
        dismissKeyboard()
        tap(button("Search hotels"))
    }

    func dismissKeyboard() {
        let returnKey = app.keyboards.buttons["Return"]
        if returnKey.waitForExistence(timeout: 3) { returnKey.tap() }
    }
}
