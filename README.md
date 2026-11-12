# Nexus XCUITest Suite

End-to-end XCUITest automation for the **Nexus Demo** iOS app (`com.bstack.nexus-demo`), organised one folder per domain and one file per workflow, and runnable on BrowserStack App Automate.

## Repository layout

```
app/
  nexus-demo.ipa                 App under test (uploaded to BrowserStack)
Nexus-app/
  Nexus-app.xcodeproj            Xcode project (shared scheme: Nexus-app)
  Nexus-appUITests/
    Support/                     Shared base class, login/OTP steps, test data
    Auth/                        Login, OTP verification
    Global/                      Network info, shake toast, IP badge
    Ecommerce/                   Browse, cart, checkout, profile
    Healthcare/                  Home, appointments, records, nearby & profile
    BFSI/                        Dashboard, account detail, ATM finder, transfer, Apple Pay, KYC, profile
    Travel/                      Home, flight search, hotel search, trips, bookings
    Standalone/                  Hub + one file per feature (biometric, IP geo, network, GPS, OTP, push, QR, media)
```

Each domain folder has a `*Flow.swift` base class that handles login for that domain, so every workflow file contains only its own tests.

## Conventions

- Every test class extends `NexusUITestCase` (or a domain base class) from `Support/`.
- Waits use `waitForExistence`; there are no sleeps.
- One selector per element, using the accessibility labels the app exposes. Dynamic values (order numbers, dates, distances) are matched by prefix or pattern, never exact text.
- Test data lives in `Support/NexusTestData.swift`. The demo accepts any email/password and any 6-digit OTP.
- Add a new workflow as a new `*UITests.swift` file in the matching domain folder.

## Prerequisites

- Xcode installed, with the developer directory selected:
  `sudo xcode-select -s /Applications/Xcode.app/Contents/Developer`
- BrowserStack credentials in your environment (never commit them):
  ```bash
  export BROWSERSTACK_USERNAME=<your username>
  export BROWSERSTACK_ACCESS_KEY=<your access key>
  ```

## Build the test runner

```bash
cd Nexus-app
xcodebuild build-for-testing \
  -project Nexus-app.xcodeproj -scheme Nexus-app \
  -sdk iphoneos -configuration Debug -destination 'generic/platform=iOS' \
  -derivedDataPath build CODE_SIGNING_ALLOWED=NO

cd build/Build/Products/Debug-iphoneos
zip -qr ../Nexus-appUITests-Runner.zip Nexus-appUITests-Runner.app
```

The deployment target is iOS 17.0 so the runner installs on BrowserStack's iPhone 15 (iOS 17.3).

## Run on BrowserStack

```bash
# 1. Upload the app under test (once per app build) -> returns a bs:// URL
curl -u "$BROWSERSTACK_USERNAME:$BROWSERSTACK_ACCESS_KEY" \
  -X POST "https://api-cloud.browserstack.com/app-automate/upload" \
  -F "file=@app/nexus-demo.ipa"

# 2. Upload the test runner
curl -u "$BROWSERSTACK_USERNAME:$BROWSERSTACK_ACCESS_KEY" \
  -X POST "https://api-cloud.browserstack.com/app-automate/xcuitest/v2/test-suite" \
  -F "file=@Nexus-app/build/Build/Products/Nexus-appUITests-Runner.zip"

# 3. Start the build
curl -u "$BROWSERSTACK_USERNAME:$BROWSERSTACK_ACCESS_KEY" \
  -X POST "https://api-cloud.browserstack.com/app-automate/xcuitest/v2/build" \
  -H "Content-Type: application/json" \
  -d '{"app":"<bs:// app url>","testSuite":"<bs:// test suite url>","devices":["iPhone 15-17.0"],"project":"Nexus_XCUI test"}'
```

Results appear in the App Automate dashboard under the project **Nexus_XCUI test**.

## Known limitations

- The `Nexus-app` target in the Xcode project is the default SwiftUI template. The tests target the UI of `nexus-demo.ipa`, which is supplied as the app under test at run time.
- **KYC:** the liveness step did not advance after taking a photo during exploration, so no test reaches "Verification Submitted!".
- **Media features** (Image, Video, File, Audio): tests only check that each screen opens. Camera/media injection with the media tried was rejected.
- **Digital Key (Travel):** no Digital Key tab was found in the app, so it has no tests.
- **Biometric Pass/Fail:** these rely on BrowserStack's injected mock alert and need a cloud session with biometric support enabled.
- **Known app defect:** after an e-commerce order, "Continue Shopping" returns to a checkout with an empty cart, $0.00 subtotal, $5.99 shipping and the Pay buttons still enabled.
