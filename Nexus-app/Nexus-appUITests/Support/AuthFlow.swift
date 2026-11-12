import XCTest

/// Reusable login + OTP flow shared by every domain (E-commerce, Healthcare, Travel use IndustryLoginView; BFSI uses DemoBank LoginView).
extension NexusUITestCase {

    func openDomain(_ domain: Domain) {
        tap(button(domain.rawValue))
    }

    func signIn(email: String = NexusData.email, password: String = NexusData.password) {
        enter(email, into: field("Email address"))
        let passwordField = app.secureTextFields["Password"]
        enter(password, into: passwordField)
        let signIn = button("Sign In")
        XCTAssertTrue(signIn.isEnabled, "Sign In should be enabled with valid credentials")
        signIn.tap()
    }

    func submitPhoneForOTP() {
        enter(NexusData.phone, into: field("Phone number"))
        tap(button("Send OTP"))
        waitFor(text("Enter the 6-digit code"))
    }

    func enterOTP(_ code: String = NexusData.otp) {
        enter(code, into: field("Digit 1 of 6"))
    }

    func completeOTP() {
        submitPhoneForOTP()
        enterOTP()
        waitFor(text("Verified successfully"))
        tap(button("Continue to app"))
        allowLocationIfPrompted()
    }

    /// Domain tile -> login -> OTP -> lands inside the domain app.
    func login(domain: Domain) {
        openDomain(domain)
        signIn()
        completeOTP()
    }
}
