import XCTest

/// Standalone #11 QR code scanner.
final class StandaloneQRScannerUITests: StandaloneUITestCase {

    func testQRScannerShowsCameraPrompt() {
        openFeature(.qr)
        waitFor(app.navigationBars["Scan QR Code"])
        waitFor(text("Point your camera at a QR code"))
    }
}
