import XCTest

/// BFSI "Find ATMs near me" (location permission + results screen).
final class BFSIATMFinderUITests: BFSIUITestCase {

    func testFindATMsNearMeOpensResultsScreen() {
        tap(button("Find ATMs near me"))
        respondToSystemAlert(button: "Allow While Using App")
        waitFor(text("ATMs Near You"))
        waitFor(button("Refresh ATMs"))
        waitFor(app.textFields["Search ATMs by name or address"])
    }
}
