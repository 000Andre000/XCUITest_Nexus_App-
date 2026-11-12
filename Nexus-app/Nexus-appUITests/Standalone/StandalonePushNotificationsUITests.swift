import XCTest

/// Standalone #10 Push notifications.
final class StandalonePushNotificationsUITests: StandaloneUITestCase {

    func testScreenShowsPermissionAndComposeForm() {
        openFeature(.push)
        assertVisible(["PERMISSION", "Notification Permission", "COMPOSE", "Delay"])
        waitFor(app.textFields["Title, Notification title"])
        waitFor(app.textFields["Body, Notification body"])
        waitFor(button("Schedule notification"))
    }

    func testAllowScheduleAndDeliveryMarksNotificationSent() {
        openFeature(.push)
        let allow = button("Allow notifications")
        if allow.waitForExistence(timeout: 3) {
            allow.tap()
            respondToSystemAlert(button: "Allow")
        }
        waitFor(text("Notifications are enabled"))

        enter("Test Title", into: app.textFields["Title, Notification title"])
        enter("Test Body", into: app.textFields["Body, Notification body"])
        tap(button("Schedule notification"))

        waitFor(text("Notification scheduled in 5s"))
        assertVisible(["SCHEDULED (1)"])
        waitFor(text("Test Title: Test Body, pending"))
        // Delivery flips the row from pending to sent after the 5s delay.
        waitFor(text("Test Title: Test Body, sent"))
    }
}
