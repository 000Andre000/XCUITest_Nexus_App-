import XCTest

/// Phone + 6-digit OTP verification (OTP-1..5), demo mode accepts any 6 digits.
final class OTPVerificationUITests: NexusUITestCase {

    func testSendOtpDisabledWithoutPhone() {
        openDomain(.ecommerce)
        signIn()
        waitFor(field("Phone number"))
        XCTAssertFalse(button("Send OTP").isEnabled)
    }

    func testOtpDemoModeHintAndResendCountdown() {
        openDomain(.ecommerce)
        signIn()
        submitPhoneForOTP()
        waitFor(text("Twilio not configured — enter any 6 digits to demo"))
        waitFor(labelBeginsWith(.staticText, "Resend in"))
    }

    func testOtpSuccessShowsVerifiedAndContinue() {
        openDomain(.ecommerce)
        signIn()
        submitPhoneForOTP()
        enterOTP()
        waitFor(text("Verified successfully"))
        XCTAssertTrue(button("Continue to app").exists)
    }
}
