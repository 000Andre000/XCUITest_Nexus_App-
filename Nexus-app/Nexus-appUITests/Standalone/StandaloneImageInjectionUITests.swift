import XCTest

/// Standalone #1 Image injection. Run with camera media injection enabled for the capture path.
final class StandaloneImageInjectionUITests: StandaloneUITestCase {

    func testImageInjectionScreenOpens() {
        openFeature(.imageInjection)
        waitFor(app.navigationBars.firstMatch)
    }
}
