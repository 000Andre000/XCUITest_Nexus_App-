# update-locators

Use when a new version of the Nexus demo app has been uploaded and the XCUITest suite must be brought back in line with it: renamed labels, moved screens, added or removed steps.

## When to use

- A new `.ipa` replaces `app/nexus-demo.ipa` (or a new `bs://` app id is selected).
- A BrowserStack run of the suite starts failing with "element not found" or an assertion on text that changed.
- Someone says the UI, copy, tab names or a flow changed.

## Inputs

- The new app: a `bs://` id from the app picker, or a path to the new `.ipa`. Never paste the app into chat.
- The old suite: `Nexus-app/Nexus-appUITests/` (one folder per domain).
- Optional: the last failing run's build id, to prioritise what broke.

## Steps

1. **Record the baseline.** Note the current app id and `git status`. Work on a feature branch named `tc/update-locators-<app-version>`; never edit on `main`.
2. **Capture the new UI.** Start a session on the new app and visit every screen the tests touch, domain by domain (Auth, Global, Ecommerce, Healthcare, BFSI, Travel, Standalone). Save one page-source dump per screen into `dumps/<version>/` (one file per screen, any text format).
3. **Find what broke.** Run:
   `python3 skills/update-locators/check_locators.py --tests Nexus-app/Nexus-appUITests --sources dumps/<version> --json dumps/<version>/report.json`
   It lists every locator the tests use that no longer exists, where it is used, and the closest labels in the new build. Exit code 1 means something is missing.
4. **Classify each miss.**
   - *Renamed*: the closest label is the same element. Update the string.
   - *Moved or split*: the element exists on another screen. Update the flow helper (`*Flow.swift`) or the test steps that reach it, not just the string.
   - *Removed*: the element is gone. Remove or rewrite the assertion deliberately and say so in the summary. Never delete a test or assertion just to get green.
   - *New required step*: a new screen, permission alert or confirmation sits between two known screens. Add it to the shared flow helper so every test benefits.
5. **Edit at the source of truth.** Locators live in the test files and `Support/` and `*Flow.swift` helpers. Prefer changing a helper (`signIn`, `selectAccount`, `searchFlights`, `openFeature`) over editing each test. Keep one selector per element, no sleeps, no dynamic text in selectors (use `labelBeginsWith` for values that change). Update `Support/NexusTestData.swift` enums when a tile or feature row label changes.
6. **Confirm the checker is clean.** Re-run step 3 until it prints "All locators still resolve". A clean check proves labels exist, not that the flows work, so continue to step 7.
7. **Compile.** `xcodebuild build-for-testing -project Nexus-app/Nexus-app.xcodeproj -scheme Nexus-app -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO -quiet`
8. **Run on BrowserStack** against the new app (see README "Run on BrowserStack"). Fix real failures from the run's logs, re-run, and repeat. After 3 consecutive failed runs of the same test, stop and report it as blocked with what you tried.
9. **Report.** List each locator changed (old to new, file), each flow change, anything removed with the reason, and any genuine product defect found. Commit with a message stating the app version and why, then push the branch.

## Verification

- `check_locators.py` exits 0 against dumps of the new build.
- The project compiles.
- The BrowserStack run of the affected tests has been observed passing; do not claim it otherwise.

## Pitfalls

- Matching text copied from the screenshot instead of the page source: curly quotes, arrows and double spaces differ (account picker rows use two spaces).
- A label that is dynamic (balances, order numbers, city) turning into a failing exact match; switch to a prefix match.
- Fixing only the string when the flow gained a step; the next screen then fails.
- Editing on `main` or committing `build/`, dumps containing personal data, or credentials.
- The Xcode target in the repo is a template; tests are validated against the uploaded `.ipa`.
