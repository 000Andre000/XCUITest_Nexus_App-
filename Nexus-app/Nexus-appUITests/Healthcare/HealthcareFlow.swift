import XCTest

/// Healthcare (CareNexus) shared steps.
class HealthcareUITestCase: NexusUITestCase {

    override func setUpWithError() throws {
        try super.setUpWithError()
        login(domain: .healthcare)
        waitFor(text("Hello, Test"))
    }

    func openFirstAppointment() {
        tapTab("Appointments")
        tap(labelBeginsWith(.button, "Dr. Sarah Chen"))
        waitFor(text("Consultation Fee"))
    }
}
