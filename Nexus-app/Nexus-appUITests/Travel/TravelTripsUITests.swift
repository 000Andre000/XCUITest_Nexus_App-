import XCTest

/// Travel Trips tab: sample trips, trip detail, my bookings; plus Profile tab.
final class TravelTripsUITests: TravelUITestCase {

    func testTripsTabListsSampleTrips() {
        tapTab("Trips")
        assertVisible(["SAMPLE TRIPS"])
        waitFor(labelBeginsWith(.button, "Tokyo, Sep 12"))
        waitFor(labelBeginsWith(.button, "Lisbon, Oct 3"))
        waitFor(labelBeginsWith(.button, "San Francisco, Nov 20"))
    }

    func testTripDetailShowsDatesTypeStatusAndTotal() {
        tapTab("Trips")
        tap(labelBeginsWith(.button, "Lisbon, Oct 3"))
        assertVisible(["Dates", "Type", "Status", "Total"])
        waitFor(text("Upcoming"))
    }

    func testProfileTabShowsAccountDetails() {
        tapTab("Profile")
        waitFor(text(NexusData.email))
        waitFor(button("Sign Out"))
    }
}
