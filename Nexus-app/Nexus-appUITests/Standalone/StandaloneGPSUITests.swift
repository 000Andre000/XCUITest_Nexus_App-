import XCTest

/// Standalone #8 GPS test.
final class StandaloneGPSUITests: StandaloneUITestCase {

    func testInitialStateShowsGpsPrompt() {
        openFeature(.gps)
        assertVisible(["GPS Location", "Get exact coordinates and reverse-geocoded address", "Tap to get your GPS location"])
        waitFor(button("Get GPS location"))
    }

    func testGetGpsLocationStartsLocating() {
        openFeature(.gps)
        tap(button("Get GPS location"))
        allowLocationIfPrompted()
        waitFor(text("Locating…"))
    }
}
