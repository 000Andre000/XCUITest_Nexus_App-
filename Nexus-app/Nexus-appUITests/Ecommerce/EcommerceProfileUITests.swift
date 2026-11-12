import XCTest

/// E-commerce Profile tab: security, preferences, push alerts, sign out.
final class EcommerceProfileUITests: EcommerceUITestCase {

    override func setUpWithError() throws {
        try super.setUpWithError()
        tapTab("Profile")
    }

    func testProfileShowsUserAndEmail() {
        assertVisible([NexusData.email, "SECURITY", "PREFERENCES"])
    }

    func testChangePasswordPlaceholderScreen() {
        tap(button("Change Password"))
        assertVisible(["This screen would connect to your auth backend."])
    }

    func testProfilePictureSheetOptions() {
        tap(app.buttons["changeProfilePicture"])
        waitFor(button("Take Photo"))
        XCTAssertTrue(button("Choose from Library").exists)
        tap(button("Cancel"))
    }

    func testSendAlertsPermissionComposeAndInAppBanner() {
        tap(app.buttons["sendAlertsButton"])
        waitFor(text("Notification Permission"))
        tap(button("Allow notifications"))
        respondToSystemAlert(button: "Allow")
        waitFor(text("Notifications are enabled"))
        tap(button("Schedule notification"))
        waitFor(text("Notification scheduled in 5s"))
        waitFor(app.otherElements["notification_banner"])
    }

    func testSignOutReturnsToLogin() {
        tap(button("Sign Out"))
        waitFor(button("Sign In"))
    }
}
