#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# release.sh — Build both APK and IPA for a given environment
#
# Usage:
#   ./scripts/release.sh             # defaults to dev
#   ./scripts/release.sh dev
#   ./scripts/release.sh prod
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV="${1:-dev}"

START_TIME=$(date +%s)

echo ""
echo "╔══════════════════════════════════════════╗"
echo "║   RELEASE BUILD  │  env: $ENV"
echo "╚══════════════════════════════════════════╝"
echo ""

# ─── Android APK ──────────────────────────────────────────────────────────────
echo "▶ Step 1/2 — Android APK"
bash "$SCRIPT_DIR/build_apk.sh" "$ENV"

# ─── iOS IPA (macOS only) ─────────────────────────────────────────────────────
if [[ "$(uname)" == "Darwin" ]]; then
  echo "▶ Step 2/2 — iOS IPA"
  bash "$SCRIPT_DIR/build_ipa.sh" "$ENV"
else
  echo "▶ Step 2/2 — iOS IPA skipped (requires macOS)"
fi

# ─── Summary ──────────────────────────────────────────────────────────────────
END_TIME=$(date +%s)
ELAPSED=$((END_TIME - START_TIME))

echo ""
echo "╔══════════════════════════════════════════╗"
echo "║   All builds complete in ${ELAPSED}s"
echo "╚══════════════════════════════════════════╝"
echo ""
