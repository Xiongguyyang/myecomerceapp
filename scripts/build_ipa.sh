#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# build_ipa.sh — Build iOS IPA for dev or prod
#
# Usage:
#   ./scripts/build_ipa.sh           # defaults to dev
#   ./scripts/build_ipa.sh dev
#   ./scripts/build_ipa.sh prod
#
# Requirements:
#   - macOS with Xcode installed
#   - Valid Apple Developer provisioning profile & certificate in Keychain
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
ENV="${1:-dev}"

# ─── Validate env ─────────────────────────────────────────────────────────────
if [[ "$ENV" != "dev" && "$ENV" != "prod" ]]; then
  echo "ERROR: Invalid environment '$ENV'. Use 'dev' or 'prod'."
  exit 1
fi

# ─── Check macOS ──────────────────────────────────────────────────────────────
if [[ "$(uname)" != "Darwin" ]]; then
  echo "ERROR: iOS builds require macOS."
  exit 1
fi

cd "$PROJECT_ROOT"

echo ""
echo "════════════════════════════════════════"
echo "  Building IPA  │  env: $ENV"
echo "════════════════════════════════════════"
echo ""

# ─── Run flutter pub get ──────────────────────────────────────────────────────
echo "▶ Running flutter pub get..."
flutter pub get

# ─── Install CocoaPods dependencies ───────────────────────────────────────────
echo "▶ Installing CocoaPods dependencies..."
cd ios && pod install --repo-update && cd ..

# ─── Build ────────────────────────────────────────────────────────────────────
if [[ "$ENV" == "prod" ]]; then
  echo "▶ Building RELEASE IPA (prod)..."
  flutter build ipa \
    --release \
    --target lib/main_prod.dart \
    --build-name="$(grep '^version:' pubspec.yaml | awk '{print $2}' | cut -d'+' -f1)" \
    --build-number="$(grep '^version:' pubspec.yaml | awk '{print $2}' | cut -d'+' -f2)"
else
  echo "▶ Building DEBUG IPA (dev)..."
  flutter build ipa \
    --target lib/main_dev.dart
fi

# ─── Result ───────────────────────────────────────────────────────────────────
OUTPUT_DIR="$PROJECT_ROOT/build/ios/ipa"

echo ""
echo "════════════════════════════════════════"
echo "  IPA built successfully!"
echo "  Output: $OUTPUT_DIR"
ls "$OUTPUT_DIR"/*.ipa 2>/dev/null && echo "  Files:  $(ls "$OUTPUT_DIR"/*.ipa | xargs -I{} basename {})" || true
echo "════════════════════════════════════════"
echo ""
