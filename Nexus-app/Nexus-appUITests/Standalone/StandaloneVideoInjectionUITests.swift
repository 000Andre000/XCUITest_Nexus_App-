import XCTest

/// Standalone #3 Video injection. Run with camera media injection enabled for the capture path.
final class StandaloneVideoInjectionUITests: StandaloneUITestCase {

    func testVideoInjectionScreenOpens() {
        openFeature(.videoInjection)
        waitFor(app.navigationBars.firstMatch)
    }
}
