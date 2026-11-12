import XCTest

/// Standalone demo shared steps (no login required, PRD 3.7).
class StandaloneUITestCase: NexusUITestCase {

    override func setUpWithError() throws {
        try super.setUpWithError()
        openDomain(.standalone)
        waitFor(text("Network Status"))
    }

    func openFeature(_ feature: StandaloneFeature) {
        let row = button(feature.rawValue)
        if !row.waitForExistence(timeout: 3) { scrollUntilVisible(row) }
        tap(row)
    }
}
