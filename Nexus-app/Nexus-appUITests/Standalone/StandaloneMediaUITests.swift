import XCTest

/// Standalone #1 Image, #3 Video, #4 File, #5 Audio entry screens.
/// Capture/injection steps need a session with camera, audio and file capabilities,
/// so these tests assert only that each screen opens from the hub.
final class StandaloneMediaUITests: StandaloneUITestCase {

    func testImageInjectionScreenOpens() {
        openFeature(.imageInjection)
        waitFor(app.navigationBars.firstMatch)
    }

    func testVideoInjectionScreenOpens() {
        openFeature(.videoInjection)
        waitFor(app.navigationBars.firstMatch)
    }

    func testFileUploadDownloadScreenOpens() {
        openFeature(.fileTransfer)
        waitFor(app.navigationBars.firstMatch)
    }

    func testAudioInjectionScreenOpens() {
        openFeature(.audioInjection)
        waitFor(app.navigationBars.firstMatch)
    }
}
