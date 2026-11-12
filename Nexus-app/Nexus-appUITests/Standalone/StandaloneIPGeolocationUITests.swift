import XCTest

/// Standalone #6 IP geolocation.
final class StandaloneIPGeolocationUITests: StandaloneUITestCase {

    func testInitialStateShowsLookupPrompt() {
        openFeature(.ipGeo)
        assertVisible(["IP Geolocation", "Lookup your public IP address and geographic location", "Tap Lookup to fetch your IP location"])
        waitFor(button("Lookup IP geolocation"))
    }

    func testLookupShowsLocationDetails() {
        openFeature(.ipGeo)
        tap(button("Lookup IP geolocation"))
        assertVisible(["Location Details", "IP Address", "Country", "Region", "City", "Postal Code", "Full Address"])
    }

    func testClearResetsToLookupPrompt() {
        openFeature(.ipGeo)
        tap(button("Lookup IP geolocation"))
        waitFor(text("Location Details"))
        tap(button("Clear geolocation results"))
        waitFor(text("Tap Lookup to fetch your IP location"))
    }
}
