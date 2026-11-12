import XCTest

/// BFSI (DemoBank) shared steps. Login uses "Email"/"Password" placeholders, not the industry login labels.
class BFSIUITestCase: NexusUITestCase {

    override func setUpWithError() throws {
        try super.setUpWithError()
        openDomain(.bfsi)
        signInToDemoBank()
        completeOTP()
        waitFor(text("Welcome back,"))
    }

    var emailField: XCUIElement { app.textFields.matching(NSPredicate(format: "placeholderValue == 'Email'")).firstMatch }
    var passwordField: XCUIElement { app.secureTextFields.matching(NSPredicate(format: "placeholderValue == 'Password'")).firstMatch }

    func signInToDemoBank(email: String = NexusData.email, password: String = NexusData.password) {
        enter(email, into: emailField)
        enter(password, into: passwordField)
        tap(button("Sign In"))
    }

    // MARK: - Account pickers (labels use two spaces between name, mask and balance)

    func accountOption(_ name: String) -> XCUIElement {
        labelBeginsWith(.button, "\(name)  xxxx")
    }

    func selectAccount(picker: String, name: String) {
        tap(button(picker))
        tap(accountOption(name))
    }

    // MARK: - Keyboard helpers

    /// Numeric/decimal pads have no Return key: focus a text field and dismiss with Return.
    func dismissKeyboardVia(_ textField: XCUIElement) {
        tap(textField)
        tap(app.keyboards.buttons["Return"])
    }
}
