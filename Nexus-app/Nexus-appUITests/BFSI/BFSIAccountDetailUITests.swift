import XCTest

/// BFSI account detail, transaction history, statement download and investment account.
final class BFSIAccountDetailUITests: BFSIUITestCase {

    func testAccountDetailShowsBalanceAndTransactionHistory() {
        tap(labelBeginsWith(.button, "Everyday Checking, xxxx"))
        assertVisible(["Account xxxx 3390", "Transaction History"])
        for action in ["Transfer", "Pay", "Statement"] {
            waitFor(button(action))
        }
        waitFor(text("Payroll Deposit"))
        waitFor(text("Whole Foods Market"))
    }

    func testStatementSheetOffersPDFDownload() {
        tap(labelBeginsWith(.button, "Everyday Checking, xxxx"))
        tap(button("Statement"))
        assertVisible(["STATEMENT PERIOD"])
        tap(button("Download Statement (PDF)"))
        closeShareSheet()
    }

    func testBackReturnsToDashboard() {
        tap(labelBeginsWith(.button, "Savings, xxxx"))
        waitFor(text("Transaction History"))
        goBack()
        waitFor(text("ACCOUNTS"))
    }

    func testInvestmentAccountDetailOpens() {
        tap(labelBeginsWith(.button, "Investment, xxxx"))
        waitFor(text("Account xxxx 8821"))
        waitFor(text("Transaction History"))
    }
}
