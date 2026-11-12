import XCTest

/// Travel flight search and flight details.
final class TravelFlightSearchUITests: TravelUITestCase {

    func testFlightSearchListsThreeResults() {
        searchFlights(to: "Tokyo")
        waitFor(labelBeginsWith(.staticText, "3 flights found"))
        for airline in ["ANA", "Japan Airlines", "United"] {
            waitFor(labelBeginsWith(.button, "\(airline), "))
        }
    }

    func testFlightDetailShowsAirlineStopsAndPaymentOptions() {
        searchFlights(to: "Tokyo")
        tap(labelBeginsWith(.button, "ANA, "))
        assertVisible(["Airline", "Stops", "Duration", "Price"])
        waitFor(button("Pay with Apple Pay"))
        waitFor(button("Pay with card"))
    }
}
