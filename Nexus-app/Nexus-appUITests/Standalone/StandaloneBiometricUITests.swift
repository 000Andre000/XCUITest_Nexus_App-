import XCTest

/// Standalone #2 Biometric test.
/// Pass/Fail rely on BrowserStack's injected "Biometric Authentication" mock alert (enableBiometric).
final class StandaloneBiometricUITests: StandaloneUITestCase {

    func testBiometricScreenShowsRunButton() {
        openFeature(.biometric)
        assertVisible(["Biometric Authentication", "Tests Face ID on this device"])
        waitFor(button("Run biometric authentication test"))
    }

    func testBiometricPassShowsSuccessAndResetClearsResult() {
        openFeature(.biometric)
        tap(button("Run biometric authentication test"))
        tap(app.alerts["Biometric Authentication"].buttons["Pass"])
        assertVisible(["Success", "Authentication succeeded."])
        tap(button("Reset biometric test"))
        XCTAssertFalse(text("Authentication succeeded.").exists)
    }

    func testBiometricFailShowsFailedResult() {
        openFeature(.biometric)
        tap(button("Run biometric authentication test"))
        tap(app.alerts["Biometric Authentication"].buttons["Fail"])
        waitFor(text("Failed"))
        waitFor(labelBeginsWith(.staticText, "The operation couldn’t be completed."))
        waitFor(button("Reset biometric test"))
    }

    func testBiometricCancelLeavesNoResult() {
        openFeature(.biometric)
        tap(button("Run biometric authentication test"))
        tap(app.alerts["Biometric Authentication"].buttons["Cancel"])
        XCTAssertFalse(text("Success").exists)
        XCTAssertFalse(text("Failed").exists)
    }
}
