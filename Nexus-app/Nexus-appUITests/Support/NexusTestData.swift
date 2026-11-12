import Foundation

/// Test data. The demo app accepts any email/password and any 6-digit OTP (Twilio demo mode).
enum NexusData {
    static let email = "test@example.com"
    static let password = "Password123!"
    static let invalidEmail = "not-an-email"
    static let phone = "+1 555 000 0000"
    static let otp = "123456"
    static let street = "1 Test Street"
    static let city = "Mumbai"
    static let zip = "400001"
}

/// Domain tile accessibility labels on the "Nexus Demo" home screen.
enum Domain: String {
    case ecommerce = "E-commerce, Shop, scan & checkout"
    case healthcare = "Healthcare, Care, records & nearby"
    case bfsi = "BFSI, Banking & transfers"
    case travel = "Travel, Flights, stays & keys"
    case standalone = "Standalone demo, Test features without the full flow"
}

/// Standalone demo feature rows (labels as exposed by the app).
enum StandaloneFeature: String {
    case imageInjection = "1, Image injection, Camera still capture"
    case biometric = "2, Biometric test, Fingerprint / face prompt"
    case videoInjection = "3, Video injection, Record + play video"
    case fileTransfer = "4, File upload & download, Document pick + share"
    case audioInjection = "5, Audio injection test, Microphone record & play"
    case ipGeo = "6, IP geo location test, Public IP → location"
    case network = "7, Network test, Connection status"
    case gps = "8, GPS test, Device GPS + reverse geocode"
    case otp = "9, OTP test, Send + verify code"
    case push = "10, Push notifications, Schedule & receive alerts"
    case qr = "11, QR code scanner, Scan QR → view text result"
}
