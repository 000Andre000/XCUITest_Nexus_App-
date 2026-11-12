import XCTest

/// Domain picker and email/password login (AUTH-1..5, AC-1..3).
final class LoginUITests: NexusUITestCase {

    func testDomainPickerShowsAllFiveTiles() {
        waitFor(text("Choose a domain"))
        for domain in [Domain.ecommerce, .healthcare, .bfsi, .travel, .standalone] {
            XCTAssertTrue(button(domain.rawValue).exists, domain.rawValue)
        }
    }

    func testSignInDisabledUntilBothFieldsFilled() {
        openDomain(.ecommerce)
        waitFor(text("Sign in to continue"))
        XCTAssertFalse(button("Sign In").isEnabled)
        enter(NexusData.email, into: field("Email address"))
        XCTAssertFalse(button("Sign In").isEnabled)
        enter(NexusData.password, into: app.secureTextFields["Password"])
        XCTAssertTrue(button("Sign In").isEnabled)
    }

    func testInvalidEmailShowsValidationMessage() {
        openDomain(.ecommerce)
        enter(NexusData.invalidEmail, into: field("Email address"))
        enter(NexusData.password, into: app.secureTextFields["Password"])
        XCTAssertFalse(button("Sign In").isEnabled)
        waitFor(text("Enter a valid email address"))
    }

    func testFaceIDButtonPresentOnLogin() {
        openDomain(.ecommerce)
        waitFor(button("Sign in with Face ID"))
    }
}
