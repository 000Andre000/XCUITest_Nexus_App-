import XCTest

/// PRD 2 global behaviours and 3.8 shared components.
final class GlobalBehaviourUITests: NexusUITestCase {

    func testNetworkInfoSheetFromShopHeader() {
        login(domain: .ecommerce)
        tap(labelBeginsWith(.button, "Network:"))
        waitFor(text("Network Info"))
        assertVisible(["Network is reachable"])
        tap(button("Done"))
    }

    func testStandaloneShowsNetworkStatusWidget() {
        openDomain(.standalone)
        waitFor(text("Network Status"))
    }

    func testShakeTogglesThemeToast() {
        openDomain(.standalone)
        waitFor(text("Network Status"))
        XCUIDevice.shared.perform(NSSelectorFromString("shake"))
        // Toast is exposed with identifier `shakeThemeToast` per PRD 2.
        waitFor(app.otherElements["shakeThemeToast"])
    }

    func testIPLocationBadgeVisibleOnDomainHome() {
        let badge = app.descendants(matching: .any)
            .matching(NSPredicate(format: "label BEGINSWITH 'IP location'")).firstMatch
        waitFor(badge)
    }
}
