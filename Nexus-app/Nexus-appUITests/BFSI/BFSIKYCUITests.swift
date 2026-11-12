import XCTest

/// BFSI KYC: intro, liveness camera permission and system camera.
final class BFSIKYCUITests: BFSIUITestCase {

    func testKYCIntroDescribesVerification() {
        tapTab("KYC")
        assertVisible([
            "Verify Your Identity",
            "We need to verify your identity to comply with KYC regulations.",
            "Your data is encrypted and secure"
        ])
        waitFor(button("Start Verification"))
    }

    func testStartVerificationOpensFacialLivenessStep() {
        tapTab("KYC")
        tap(button("Start Verification"))
        waitFor(text("Position your face in the circle"))
        waitFor(button("Open Front Camera"))
    }

    func testLivenessCameraRequestsPermissionAndOpensSystemCamera() {
        tapTab("KYC")
        tap(button("Start Verification"))
        tap(button("Open Front Camera"))
        respondToSystemAlert(button: "Allow")
        waitFor(app.buttons["Take Picture"])
        tap(app.buttons["Cancel"])
        waitFor(text("Position your face in the circle"))
    }
}
