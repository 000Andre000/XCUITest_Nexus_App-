import XCTest

/// Travel home tab and tab bar.
final class TravelHomeUITests: TravelUITestCase {

    func testHomeShowsGreetingCategoriesAndUpcomingTrips() {
        assertVisible(["Hello, Test", "Where to next?", "Upcoming Trips", "Hot Deals"])
        for category in ["Flights", "Hotels", "Cars", "Trains"] {
            XCTAssertTrue(app.staticTexts[category].exists || app.buttons[category].exists, "Missing category \(category)")
        }
        waitFor(labelBeginsWith(.button, "Tokyo, Sep 12"))
        waitFor(labelBeginsWith(.button, "Lisbon, Oct 3"))
    }

    func testTabBarExposesAllSections() {
        for tab in ["Home", "Search", "Trips", "Profile"] {
            XCTAssertTrue(app.tabBars.buttons[tab].waitForExistence(timeout: timeout), "Missing tab \(tab)")
        }
    }
}
