import XCTest

/// Standalone #7 Network test.
final class StandaloneNetworkUITests: StandaloneUITestCase {

    func testNetworkTestShowsConnectionDetails() {
        openFeature(.network)
        waitFor(app.navigationBars["Network Test"])
        assertVisible(["Connected", "Network Details", "Interface", "Metered (Cellular)", "Low Data Mode", "Est. Speed", "Measured Speed"])
    }
}
