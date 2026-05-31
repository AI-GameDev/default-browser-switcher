#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION="${VERSION:-$(tr -d '[:space:]' < "$ROOT_DIR/VERSION")}"
CONFIGURATION="${CONFIGURATION:-release}"
RELEASE_DIR="$ROOT_DIR/dist/release/$VERSION"
STAGING_DIR="$RELEASE_DIR/staging"
APP_STAGE_DIR="$STAGING_DIR/app"
CLI_DIR="$STAGING_DIR/setbrowser-cli-$VERSION"
APP_ZIP="$RELEASE_DIR/SetBrowser-$VERSION-macOS-app.zip"
CLI_ZIP="$RELEASE_DIR/setbrowser-$VERSION-macOS-cli.zip"
CHECKSUMS="$RELEASE_DIR/SHA256SUMS.txt"

cd "$ROOT_DIR"

swift test
VERSION="$VERSION" CONFIGURATION="$CONFIGURATION" "$ROOT_DIR/scripts/build-app-bundle.sh"
swift build -c "$CONFIGURATION" --product setbrowser

rm -rf "$RELEASE_DIR"
mkdir -p "$APP_STAGE_DIR" "$CLI_DIR"

ditto "$ROOT_DIR/dist/SetBrowser.app" "$APP_STAGE_DIR/SetBrowser.app"

cp "$ROOT_DIR/.build/$CONFIGURATION/setbrowser" "$CLI_DIR/setbrowser"
chmod +x "$CLI_DIR/setbrowser"
cp "$ROOT_DIR/LICENSE" "$CLI_DIR/LICENSE"
cp "$ROOT_DIR/PRIVACY.md" "$CLI_DIR/PRIVACY.md"

xattr -cr "$STAGING_DIR" 2>/dev/null || true

(
  cd "$APP_STAGE_DIR"
  COPYFILE_DISABLE=1 zip -r -X "$APP_ZIP" SetBrowser.app >/dev/null
)

(
  cd "$STAGING_DIR"
  COPYFILE_DISABLE=1 zip -r -X "$CLI_ZIP" "$(basename "$CLI_DIR")" >/dev/null
)

(
  cd "$RELEASE_DIR"
  shasum -a 256 "$(basename "$APP_ZIP")" "$(basename "$CLI_ZIP")" > "$CHECKSUMS"
)

rm -rf "$STAGING_DIR"

echo "Built release artifacts in $RELEASE_DIR"
echo "$APP_ZIP"
echo "$CLI_ZIP"
echo "$CHECKSUMS"
