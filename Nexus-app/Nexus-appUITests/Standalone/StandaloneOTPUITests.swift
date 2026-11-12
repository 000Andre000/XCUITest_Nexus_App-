import XCTest

/// Standalone #9 OTP test (demo mode accepts any 6 digits).
final class StandaloneOTPUITests: StandaloneUITestCase {

    func testSendOtpDisabledWithoutPhone() {
        openFeature(.otp)
        waitFor(field("Phone number"))
        XCTAssertFalse(button("Send OTP").isEnabled)
    }

    func testSendAndVerifyOtpInDemoMode() {
        openFeature(.otp)
        enter(NexusData.phone, into: field("Phone number"))
        tap(button("Send OTP"))
        waitFor(text("Enter the 6-digit code"))
        enterOTP()
        waitFor(text("Verified successfully"))
    }
}
