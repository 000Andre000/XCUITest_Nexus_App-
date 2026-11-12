import XCTest

/// Travel end-to-end bookings paid by card: confirmation, receipt, My Bookings.
final class TravelBookingUITests: TravelUITestCase {

    func testBookFlightWithCardShowsConfirmationAndReceipt() {
        searchFlights(to: "Tokyo")
        tap(labelBeginsWith(.button, "ANA, "))
        tap(button("Pay with card"))
        waitFor(text("Flight Booked!"))
        waitFor(text("Your flight to Tokyo is confirmed."))
        waitFor(text("Paid via Card"))
        waitFor(button("Download receipt as PDF"))
    }

    func testBookHotelWithCardShowsConfirmation() {
        searchHotels(in: "Tokyo")
        tap(labelBeginsWith(.button, "Grand Tokyo Hotel, "))
        tap(button("Pay with card"))
        waitFor(text("Hotel Booked!"))
        waitFor(text("Your stay at Grand Tokyo Hotel is confirmed."))
        waitFor(text("Paid via Card"))
    }

    func testBookingsAppearUnderMyBookings() {
        searchFlights(to: "Tokyo")
        tap(labelBeginsWith(.button, "ANA, "))
        tap(button("Pay with card"))
        waitFor(text("Flight Booked!"))
        tapTab("Trips")
        assertVisible(["MY BOOKINGS"])
        waitFor(labelBeginsWith(.staticText, "ANA"))
    }
}
