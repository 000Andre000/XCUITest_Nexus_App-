# Nexus XCUITest Suite

End-to-end XCUITest automation for the **Nexus Demo** iOS app (`com.bstack.nexus-demo`), organised one folder per domain and one file per workflow, and runnable on BrowserStack App Automate.

## Repository layout

```
app/
  nexus-demo.ipa                 App under test (uploaded to BrowserStack)
skills/
  update-locators/               Skill + checker to refresh locators/flows after a new app version
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

## Keeping tests in sync with new app versions (`update-locators` skill)

When a new version of the app is uploaded, labels, tab names or flows may change. The `skills/update-locators/` folder holds a repeatable procedure plus a checker script that finds the tests that would break.

```
skills/update-locators/
  SKILL.md              Step-by-step procedure (the skill itself)
  check_locators.py     Reports test locators that no longer exist in the new build
```

### Integrate it

1. **As a Test Companion skill (recommended).** Open the Skills panel, create a skill from `skills/update-locators/SKILL.md` (paste the body, name it `update-locators`), and pick Workspace so it is available to everyone using this repo. Run it with `/update-locators`.
2. **Without Test Companion.** Follow `SKILL.md` by hand; it is plain Markdown. Only `python3` is needed for the checker (no packages to install).
3. **In CI (optional).** Add a step after dumping the new build's screens:
   ```bash
   python3 skills/update-locators/check_locators.py \
     --tests Nexus-app/Nexus-appUITests --sources dumps/<version>
   ```
   It exits 1 when any locator is missing, so the job fails before the BrowserStack run is wasted.

### Use it when a new version is uploaded

1. Upload the new `.ipa` and select the new `bs://` app id.
2. Create a branch: `git switch -c tc/update-locators-<version>`.
3. Run the skill: it opens a session on the new build, visits every screen the tests use and saves one page-source dump per screen to `dumps/<version>/`.
4. Check what broke:
   ```bash
   python3 skills/update-locators/check_locators.py \
     --tests Nexus-app/Nexus-appUITests \
     --sources dumps/<version> \
     --json dumps/<version>/report.json
   ```
   Each miss shows the locator, the file and line using it, and the closest labels in the new build.
5. Fix each miss in the right place: a renamed label is a string change, a moved or new screen is a change to the domain `*Flow.swift` helper, a removed element is a deliberate test change (never deleted just to get green).
6. Re-run the checker until it reports `All locators still resolve`, then compile and run the affected tests on BrowserStack (see above).
7. Commit with the app version in the message and push the branch.

### What the checker does and does not prove

- It reads string literals passed to `button()`, `text()`, `field()`, `app.<type>[...]`, `assertVisible`, `tapTab`, `selectAccount` and `labelBeginsWith`, plus the domain and feature enums, and compares them with the labels, names, values, identifiers and placeholders in the dumps.
- Prefix selectors (`labelBeginsWith`) pass when any label starts with the prefix.
- A clean report means every label still exists in the dumps you captured. It does not prove the flows work, so always finish with a BrowserStack run.
- Dumps must cover every screen the tests touch; a screen you did not capture will show its locators as missing.
- Keep `dumps/` out of commits if the dumps hold personal data.

## Known limitations

- The `Nexus-app` target in the Xcode project is the default SwiftUI template. The tests target the UI of `nexus-demo.ipa`, which is supplied as the app under test at run time.
- **KYC:** the liveness step did not advance after taking a photo during exploration, so no test reaches "Verification Submitted!".
- **Media features** (Image, Video, File, Audio): tests only check that each screen opens. Camera/media injection with the media tried was rejected.
- **Digital Key (Travel):** no Digital Key tab was found in the app, so it has no tests.
- **Biometric Pass/Fail:** these rely on BrowserStack's injected mock alert and need a cloud session with biometric support enabled.
- **Known app defect:** after an e-commerce order, "Continue Shopping" returns to a checkout with an empty cart, $0.00 subtotal, $5.99 shipping and the Pay buttons still enabled.
