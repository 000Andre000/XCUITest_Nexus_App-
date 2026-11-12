import XCTest

/// BFSI dashboard and tab bar.
final class BFSIDashboardUITests: BFSIUITestCase {

    func testDashboardShowsAccountsAndRecentActivity() {
        assertVisible(["Welcome back,", "ACCOUNTS", "RECENT ACTIVITY"])
        for account in ["Everyday Checking", "Savings", "Credit Card", "Investment"] {
            waitFor(labelBeginsWith(.button, "\(account), xxxx"))
        }
        waitFor(button("Find ATMs near me"))
    }

    func testTabBarExposesAllSections() {
        for tab in ["Transfer", "KYC", "Profile"] {
            XCTAssertTrue(app.tabBars.buttons[tab].waitForExistence(timeout: timeout), "Missing tab \(tab)")
        }
        XCTAssertEqual(app.tabBars.buttons.count, 5)
    }
}
