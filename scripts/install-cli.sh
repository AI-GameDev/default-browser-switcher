#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PREFIX="${PREFIX:-/usr/local/bin}"
CONFIGURATION="${CONFIGURATION:-release}"

cd "$ROOT_DIR"
swift build -c "$CONFIGURATION" --product setbrowser

mkdir -p "$PREFIX"
cp ".build/$CONFIGURATION/setbrowser" "$PREFIX/setbrowser"
chmod +x "$PREFIX/setbrowser"

echo "Installed setbrowser to $PREFIX"
