import XCTest

/// PRD 3.4: health records list, download, upload picker.
final class HealthcareRecordsUITests: HealthcareUITestCase {

    override func setUpWithError() throws {
        try super.setUpWithError()
        tapTab("Records")
    }

    func testRecordsListShowsAllRecords() {
        assertVisible(["MY RECORDS", "Blood Test Results", "Annual Physical", "Vaccination Record"])
    }

    func testDownloadRecordOpensShareSheet() {
        tap(button("Download Blood Test Results"))
        waitFor(text("HealthRecord"))
        closeShareSheet()
    }

    func testUploadOpensDocumentPicker() {
        tap(button("Upload a medical record file"))
        waitFor(button("Cancel"))
        tap(button("Cancel"))
    }
}
