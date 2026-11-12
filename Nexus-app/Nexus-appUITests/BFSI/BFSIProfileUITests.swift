import XCTest

/// BFSI profile tab (shared layout) and sign out.
final class BFSIProfileUITests: BFSIUITestCase {

    func testProfileShowsAccountSecurityAndPreferences() {
        tapTab("Profile")
        waitFor(text(NexusData.email))
        waitFor(app.buttons["changeProfilePicture"])
        waitFor(button("Change Password"))
        waitFor(app.buttons["sendAlertsButton"])
        waitFor(button("Sign Out"))
    }

    func testSecurityAndNotificationTogglesPresent() {
        tapTab("Profile")
        XCTAssertTrue(app.switches["Face ID Sign-In"].waitForExistence(timeout: timeout))
        XCTAssertTrue(app.switches["Push Notifications"].exists)
    }

    func testSignOutReturnsToLoginWithFaceIDOption() {
        tapTab("Profile")
        tap(button("Sign Out"))
        waitFor(button("Sign In"))
        waitFor(button("Sign in with Face ID"))
    }
}
