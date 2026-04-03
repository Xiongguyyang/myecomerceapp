#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# build_apk.sh — Build Android APK for dev or prod
#
# Usage:
#   ./scripts/build_apk.sh           # defaults to dev
#   ./scripts/build_apk.sh dev
#   ./scripts/build_apk.sh prod
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

cd "$PROJECT_ROOT"

echo ""
echo "════════════════════════════════════════"
echo "  Building APK  │  env: $ENV"
echo "════════════════════════════════════════"
echo ""

# ─── Run flutter pub get ──────────────────────────────────────────────────────
echo "▶ Running flutter pub get..."
flutter pub get

# ─── Build ────────────────────────────────────────────────────────────────────
if [[ "$ENV" == "prod" ]]; then
  echo "▶ Building RELEASE APK (prod)..."
  flutter build apk \
    --release \
    --target lib/main_prod.dart \
    --build-name="$(grep '^version:' pubspec.yaml | awk '{print $2}' | cut -d'+' -f1)" \
    --build-number="$(grep '^version:' pubspec.yaml | awk '{print $2}' | cut -d'+' -f2)"

  OUTPUT_DIR="$PROJECT_ROOT/build/app/outputs/flutter-apk"
  APK_NAME="app-release.apk"
else
  echo "▶ Building DEBUG APK (dev)..."
  flutter build apk \
    --debug \
    --target lib/main_dev.dart

  OUTPUT_DIR="$PROJECT_ROOT/build/app/outputs/flutter-apk"
  APK_NAME="app-debug.apk"
fi

# ─── Result ───────────────────────────────────────────────────────────────────
echo ""
echo "════════════════════════════════════════"
echo "  APK built successfully!"
echo "  Output: $OUTPUT_DIR/$APK_NAME"
echo "  Size:   $(du -sh "$OUTPUT_DIR/$APK_NAME" 2>/dev/null | cut -f1 || echo 'N/A')"
echo "════════════════════════════════════════"
echo ""
