import XCTest

/// Standalone #4 File upload & download entry screen.
/// Image (#1), Video (#3) and Audio (#5) injection live in their own files so CI can run them separately.
final class StandaloneMediaUITests: StandaloneUITestCase {

    func testFileUploadDownloadScreenOpens() {
        openFeature(.fileTransfer)
        waitFor(app.navigationBars.firstMatch)
    }
}
