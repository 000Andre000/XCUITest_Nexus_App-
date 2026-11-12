import XCTest

/// PRD 3.4: patient home, prescriptions, lab results.
final class HealthcareHomeUITests: HealthcareUITestCase {

    func testHomeShowsSections() {
        assertVisible(["Stay healthy today", "Upcoming Appointments", "Recent Lab Results", "Active Prescriptions"])
    }

    func testHomeShowsLabResultsAndPrescription() {
        assertVisible(["Complete Blood Count", "HbA1c"])
        XCTAssertTrue(labelBeginsWith(.any, "Metformin").exists || text("Metformin 500mg").exists)
    }

    func testHomeShowsUpcomingAppointments() {
        XCTAssertTrue(labelBeginsWith(.button, "Dr. Sarah Chen").exists)
        XCTAssertTrue(labelBeginsWith(.button, "Dr. Marcus Lee").exists)
    }
}
