import XCTest

/// Travel hotel search and hotel details.
final class TravelHotelSearchUITests: TravelUITestCase {

    func testHotelSearchListsThreeResults() {
        searchHotels(in: "Tokyo")
        waitFor(labelBeginsWith(.staticText, "3 hotels found"))
        for hotel in ["Grand Tokyo Hotel", "Tokyo Boutique Inn", "Tokyo Budget Stay"] {
            waitFor(labelBeginsWith(.button, "\(hotel), "))
        }
    }

    func testHotelDetailShowsRatingAmenitiesAndPaymentOptions() {
        searchHotels(in: "Tokyo")
        tap(labelBeginsWith(.button, "Grand Tokyo Hotel, "))
        assertVisible(["Rating", "Reviews", "Per night", "Amenities"])
        waitFor(button("Pay with Apple Pay"))
        waitFor(button("Pay with card"))
    }
}
