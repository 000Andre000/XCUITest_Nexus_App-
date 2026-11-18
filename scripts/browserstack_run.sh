#!/usr/bin/env bash
# Build the XCUITest runner, upload app + suite to App Automate and start a build.
# Usage: scripts/browserstack_run.sh <build-name> <only-testing,comma,separated> [capability flags...]
# Env (required): BROWSERSTACK_USERNAME, BROWSERSTACK_ACCESS_KEY
# Env (optional): DEVICES (default "iPhone 15-17"), APP_PATH, PROJECT_NAME,
#                 CAMERA_INJECTION=true + CAMERA_MEDIA_URL=bs://<media id>, WCAG_VERSION, APP_URL
set -euo pipefail

BUILD_NAME="${1:?build name required}"
ONLY_TESTING="${2:-}"
DEVICES="${DEVICES:-iPhone 17-26}"
APP_PATH="${APP_PATH:-app/nexus-demo.ipa}"
PROJECT_NAME="${PROJECT_NAME:-Nexus_XCUI test}"
: "${BROWSERSTACK_USERNAME:?missing}" "${BROWSERSTACK_ACCESS_KEY:?missing}"

# Keep secrets out of logs even if a tool echoes them.
if [ -n "${GITHUB_ACTIONS:-}" ]; then
  echo "::add-mask::$BROWSERSTACK_USERNAME"
  echo "::add-mask::$BROWSERSTACK_ACCESS_KEY"
fi
AUTH="$BROWSERSTACK_USERNAME:$BROWSERSTACK_ACCESS_KEY"
API="https://api-cloud.browserstack.com/app-automate"

# curl -K reads the credentials from stdin so they never appear in argv.
bs_curl() { printf 'user = "%s"\n' "$AUTH" | curl -sS --fail-with-body -K - "$@"; }

echo "Building test runner..."
(
  cd Nexus-app
  xcodebuild build-for-testing \
    -project Nexus-app.xcodeproj -scheme Nexus-app \
    -sdk iphoneos -configuration Debug -destination 'generic/platform=iOS' \
    -derivedDataPath build CODE_SIGNING_ALLOWED=NO -quiet
  cd build/Build/Products/Debug-iphoneos
  rm -f ../Nexus-appUITests-Runner.zip
  zip -qr ../Nexus-appUITests-Runner.zip Nexus-appUITests-Runner.app
)

# APP_URL (a bs:// id of an already-uploaded, XCUITest-compatible app) skips the upload.
if [ -z "${APP_URL:-}" ]; then
  echo "Uploading app..."
  APP_URL=$(bs_curl -X POST "$API/upload" -F "file=@$APP_PATH" | python3 -c 'import sys,json;print(json.load(sys.stdin)["app_url"])')
fi
echo "Uploading test suite..."
SUITE_URL=$(bs_curl -X POST "$API/xcuitest/v2/test-suite" \
  -F "file=@Nexus-app/build/Build/Products/Nexus-appUITests-Runner.zip" | python3 -c 'import sys,json;print(json.load(sys.stdin)["test_suite_url"])')

PAYLOAD=$(BUILD_NAME="$BUILD_NAME" ONLY_TESTING="$ONLY_TESTING" DEVICES="$DEVICES" APP_URL="$APP_URL" \
  SUITE_URL="$SUITE_URL" PROJECT_NAME="$PROJECT_NAME" python3 - <<'PY'
import json, os
e = os.environ
p = {
    "app": e["APP_URL"],
    "testSuite": e["SUITE_URL"],
    "devices": [d.strip() for d in e["DEVICES"].split(",") if d.strip()],
    "project": e["PROJECT_NAME"],
    "buildName": e["BUILD_NAME"],
    "networkLogs": True,          # network logs on every run
    "enableResultBundle": True,   # xcresult bundle
    "deviceLogs": True,
    "video": True,
    "appProfiling": True,         # performance / app profiling on every run
    "accessibility": True,        # a11y scan on every run
    "accessibilityOptions": {"wcagVersion": e.get("WCAG_VERSION") or "wcag21aa"},
}
if e["ONLY_TESTING"]:
    p["only-testing"] = [t.strip() for t in e["ONLY_TESTING"].split(",") if t.strip()]
# Camera injection needs an uploaded media id (bs://...). Audio injection is not
# supported for XCUITest on App Automate (Maestro only), so it is never requested.
if e.get("CAMERA_INJECTION") == "true" and e.get("CAMERA_MEDIA_URL"):
    p["enableCameraImageInjection"] = True
    p["cameraInjectionMedia"] = e["CAMERA_MEDIA_URL"]
print(json.dumps(p))
PY
)

[ -n "${DEBUG_PAYLOAD_KEYS:-}" ] && printf "%s" "$PAYLOAD" | python3 -c "import sys,json;print(sorted(json.load(sys.stdin)))"
echo "Starting build '$BUILD_NAME' on: $DEVICES"
# The payload goes through a temp file: curl's stdin is already used for the credentials (-K -).
PAYLOAD_FILE=$(mktemp)
trap 'rm -f "$PAYLOAD_FILE"' EXIT
printf '%s' "$PAYLOAD" > "$PAYLOAD_FILE"
RESP=$(bs_curl -X POST "$API/xcuitest/v2/build" \
  -H "Content-Type: application/json" -d "@$PAYLOAD_FILE") || { echo "Build start failed: $RESP" >&2; exit 1; }
BUILD_ID=$(printf '%s' "$RESP" | python3 -c 'import sys,json;print(json.load(sys.stdin)["build_id"])')
echo "Build id: $BUILD_ID"
[ -n "${GITHUB_OUTPUT:-}" ] && echo "build_id=$BUILD_ID" >> "$GITHUB_OUTPUT"

echo "Waiting for build to finish..."
while true; do
  STATUS=$(bs_curl "$API/xcuitest/v2/builds/$BUILD_ID" | python3 -c 'import sys,json;print(json.load(sys.stdin).get("status",""))')
  echo "status: $STATUS"
  case "$STATUS" in
    passed) exit 0 ;;
    failed|error|timedout|skipped) exit 1 ;;
  esac
  sleep 20
done
