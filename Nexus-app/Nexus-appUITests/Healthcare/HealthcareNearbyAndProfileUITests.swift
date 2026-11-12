import XCTest

/// PRD 3.4 / LOC-6: nearby providers (static sample data) and profile.
final class HealthcareNearbyAndProfileUITests: HealthcareUITestCase {

    func testNearbyProvidersListIsStaticSampleData() {
        tapTab("Nearby")
        waitFor(button("Find nearby providers"))
        assertVisible(["NEARBY PROVIDERS", "Downtown Urgent Care", "City General Hospital", "Wellness Pharmacy"])
    }

    func testLocateKeepsProviderList() {
        tapTab("Nearby")
        tap(button("Find nearby providers"))
        allowLocationIfPrompted()
        assertVisible(["Downtown Urgent Care"])
    }

    func testProfileShowsUserAndSignOut() {
        tapTab("Profile")
        assertVisible([NexusData.email])
        tap(button("Sign Out"))
        waitFor(button("Sign In"))
    }
}
