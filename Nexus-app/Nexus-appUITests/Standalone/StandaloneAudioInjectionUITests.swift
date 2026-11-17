import XCTest

/// Standalone #5 Audio injection. Run with audio injection enabled for the record/play path.
final class StandaloneAudioInjectionUITests: StandaloneUITestCase {

    func testAudioInjectionScreenOpens() {
        openFeature(.audioInjection)
        waitFor(app.navigationBars.firstMatch)
    }
}
