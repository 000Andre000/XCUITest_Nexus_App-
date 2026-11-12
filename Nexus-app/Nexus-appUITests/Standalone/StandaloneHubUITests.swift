import XCTest

/// All 11 Standalone features are reachable from the hub and return to it.
final class StandaloneHubUITests: StandaloneUITestCase {

    private let allFeatures: [StandaloneFeature] = [
        .imageInjection, .biometric, .videoInjection, .fileTransfer, .audioInjection,
        .ipGeo, .network, .gps, .otp, .push, .qr,
    ]

    func testHubListsAllElevenFeatures() {
        for feature in allFeatures {
            let row = button(feature.rawValue)
            if !row.exists { scrollUntilVisible(row) }
            XCTAssertTrue(row.exists, feature.rawValue)
        }
    }

    func testHubShowsNetworkStatusChip() {
        waitFor(text("Network Status"))
        waitFor(labelBeginsWith(.button, "Network: "))
    }

    func testFeaturesWithoutPermissionPromptsOpenAndReturnToHub() {
        let expectedTitles: [(StandaloneFeature, String)] = [
            (.biometric, "Biometric Test"),
            (.ipGeo, "IP Geolocation"),
            (.network, "Network Test"),
            (.gps, "GPS Test"),
            (.push, "Push Notifications"),
        ]
        for (feature, title) in expectedTitles {
            openFeature(feature)
            waitFor(app.navigationBars[title])
            goBack()
            waitFor(text("Network Status"))
        }
    }
}
