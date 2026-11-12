import XCTest

/// PRD 3.4: appointments list/detail and appointment payment.
final class HealthcareAppointmentsUITests: HealthcareUITestCase {

    func testAppointmentsListUpcomingAndPast() {
        tapTab("Appointments")
        assertVisible(["UPCOMING", "PAST"])
    }

    func testAppointmentDetailShowsFeeAndPaymentOptions() {
        openFirstAppointment()
        assertVisible(["Date", "Consultation Fee", "$150.00"])
        XCTAssertTrue(button("Pay with Apple Pay").exists)
        XCTAssertTrue(button("Pay with card").exists)
    }

    func testPayWithCardConfirmsPaymentAndReceipt() {
        openFirstAppointment()
        tap(button("Pay with card"))
        waitFor(text("Payment Confirmed"))
        XCTAssertTrue(text("Paid via Card").exists)
        tap(button("Download receipt as PDF"))
        closeShareSheet()
    }
}
