#!/bin/bash
# Komodo Flutter Wallet - macOS Apple Silicon Build Orchestrator
#
# Usage:
#   ./build_macos.sh [--release|--debug] [--skip-sign] [--help]
#
#   --release    Release build (default).
#   --debug      Faster debug build for iteration (still needs the ad-hoc
#                re-sign step below).
#   --skip-sign  Build only; skip the ad-hoc codesign repair step.
set -euo pipefail

echo "=== Komodo Flutter Wallet: macOS Build Script ==="

BUILD_MODE="--release"
BUILD_CONFIG="Release"
SKIP_SIGN=false

for arg in "$@"; do
  case "$arg" in
    --release) BUILD_MODE="--release"; BUILD_CONFIG="Release" ;;
    --debug) BUILD_MODE="--debug"; BUILD_CONFIG="Debug" ;;
    --skip-sign) SKIP_SIGN=true ;;
    -h|--help)
      grep -E '^# (Usage:|  --)' "$0" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    *)
      echo "Unknown argument: $arg (use --help for usage)" >&2
      exit 1
      ;;
  esac
done

echo "Build mode: $BUILD_MODE (configuration: $BUILD_CONFIG, re-sign: $([ "$SKIP_SIGN" = true ] && echo skipped || echo enabled))"

# 1. Environment Check & Homebrew Installations
echo "[1/5] Checking environment dependencies..."

if ! command -v brew &> /dev/null; then
    echo "Error: Homebrew is not installed. Please install Homebrew first." >&2
    exit 1
fi

if ! xcodebuild -version &> /dev/null; then
    echo "Error: Xcode command-line tools are not installed." >&2
    echo "Install Xcode from the App Store, then run: xcode-select --install" >&2
    exit 1
fi

if ! command -v flutter &> /dev/null; then
    echo "Installing Flutter via Homebrew..."
    brew install --cask flutter
fi

# Pin floor: pubspec.yaml requires Flutter >= 3.35.3 (tested with 3.47.5).
if command -v flutter &> /dev/null; then
    FLUTTER_VERSION="$(flutter --version --machine 2>/dev/null | python3 -c 'import json,sys; print(json.load(sys.stdin).get("frameworkVersion",""))' 2>/dev/null || true)"
    if [ -n "${FLUTTER_VERSION:-}" ]; then
        echo "Flutter version: $FLUTTER_VERSION (required: >= 3.35.3)"
    fi
fi

if ! command -v pod &> /dev/null; then
    echo "Installing CocoaPods via Homebrew..."
    brew install cocoapods
fi

# Ensure Rust is available for the KDF compilation fallback
if ! command -v cargo &> /dev/null; then
    echo "Warning: Cargo (Rust) is not in PATH. Native core build might fail if prebuilt binaries are unavailable."
fi

# 2. Configuration Restoration
echo "[2/5] Verifying project configuration..."
if [ ! -f "pubspec.yaml" ]; then
    echo "Root pubspec.yaml is missing. Reconstructing a minimal workspace pubspec..."
    echo "WARNING: the restored manifest pins only floors — run 'flutter pub upgrade' + commit." >&2
    cat << 'EOF' > pubspec.yaml
name: web_dex
description: Komodo Flutter Wallet
version: 1.0.0+1
publish_to: none

environment:
  sdk: ">=3.8.1 <4.0.0"
  flutter: ">=3.35.3"

resolution: workspace

dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  flutter_bloc: ^9.1.1
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  get_it: ^8.2.0
  path_provider: ^2.1.5
  easy_localization: ^3.0.7+1
  package_info_plus: ^9.0.1
  universal_html: ^2.3.0
  flutter_window_close: ^1.3.0
  feedback: ^3.2.0
  window_size: ^0.2.0
  url_launcher: ^6.3.2
  firebase_analytics: ^12.6.0
  firebase_core: ^4.15.0
  matomo_tracker: ^6.1.0
  bloc_concurrency: ^0.3.0
  file_picker: ^11.0.3
  encrypt: ^5.0.3
  flutter_inappwebview: ^6.1.5
  flutter_svg: ^2.3.0
  qr_flutter: ^4.1.0
  ntp: ^2.0.0
  formz: ^0.8.1
  flutter_markdown: ^0.7.7+1
  video_player: ^2.14.0
  flutter_slidable: ^4.0.3
  badges: ^4.0.1

  # Path dependencies for internal SDK and packages
  komodo_defi_sdk:
    path: sdk/komodo-defi-sdk/packages/komodo_defi_sdk
  komodo_defi_types:
    path: sdk/komodo-defi-sdk/packages/komodo_defi_types
  komodo_cex_market_data:
    path: sdk/komodo-defi-sdk/packages/komodo_cex_market_data
  komodo_ui:
    path: sdk/komodo-defi-sdk/packages/komodo_ui
  dragon_logs:
    path: sdk/komodo-defi-sdk/packages/dragon_logs
  dragon_charts_flutter:
    path: sdk/komodo-defi-sdk/packages/dragon_charts_flutter
  app_theme:
    path: app_theme
  komodo_ui_kit:
    path: packages/komodo_ui_kit
  komodo_persistence_layer:
    path: packages/komodo_persistence_layer

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0

flutter:
  uses-material-design: true
  assets:
    - assets/
    - assets/config/
    - assets/translations/
    - assets/logo/
EOF
    echo "Restored pubspec.yaml."
fi

# 3. Fetch Dependencies
echo "[3/5] Resolving Flutter and macOS dependencies..."
flutter pub get

# Navigate to macOS directory to ensure pods are installed
if [ ! -f "macos/Podfile" ]; then
    echo "Error: macos/Podfile is missing — cannot run pod install." >&2
    exit 1
fi
cd macos
pod install
cd ..

# 4. Build Application
echo "[4/5] Compiling native macOS executable (Apple Silicon, $BUILD_MODE)..."
# The komodo_wallet_build_transformer will automatically trigger during this step
# to download/compile the native Rust `libkdf` library for macOS arm64.

APP_PATH="build/macos/Build/Products/$BUILD_CONFIG/Komodo Flutter Wallet.app"
BUILD_LOG="build/flutter_build.log"
mkdir -p build

echo "  NOTE: a '** BUILD FAILED **' CodeSign error near the end of this step is"
echo "  EXPECTED — the KDF framework is installed after Xcode signs the bundle."
echo "  It is repaired automatically in step 5. This script will tell you clearly"
echo "  if the build genuinely failed."

# Stream the build output live (tee) while capturing it, so a genuine failure
# can be distinguished from the expected CodeSign one. pipefail makes the
# pipeline propagate flutter's exit code rather than tee's.
set -o pipefail
if flutter build macos "$BUILD_MODE" 2>&1 | tee "$BUILD_LOG"; then
  echo "Flutter build completed successfully."
else
  if grep -q "code object is not signed at all" "$BUILD_LOG" && [ -d "$APP_PATH" ]; then
    echo ""
    echo "  The failure above was the expected CodeSign issue only — the app bundle"
    echo "  was produced, and step 5 will repair its signature. Continuing..."
    echo ""
  else
    echo "" >&2
    echo "ERROR: flutter build failed for an unexpected reason." >&2
    echo "Last 60 lines of build output:" >&2
    tail -60 "$BUILD_LOG" >&2
    exit 1
  fi
fi

# 5. Ad-hoc Signing (local development only)
# The KDF install script copies the framework after Xcode's signing phase,
# leaving the bundle unsigned, so sign in layers: inner binaries first,
# then the app itself. NOTE: sign WITHOUT entitlements here. There are no
# Apple signing identities on a fresh dev machine, and keychain-access-groups
# is a restricted entitlement: ad-hoc signatures claiming it are rejected at
# launch (launchd "Launch failed"), while non-restricted entitlements (e.g.
# network.client) launch fine. The keychain is therefore unreachable in these
# builds (-34018); SecureRpcPasswordMixin and SecureLocalStorage fall back to
# SharedPreferences for local development. For TestFlight/distribution, sign
# with a real Apple identity together with macos/Runner/Release.entitlements
# (sandbox + keychain-access-groups), which enables secure storage.
# Gatekeeper treats ad-hoc apps as from an "unidentified developer": first
# launch via Right-click > Open.
if [ "$SKIP_SIGN" = true ]; then
  echo ""
  echo "=== Build Complete (unsigned) ==="
  echo "The native executable can be found at:"
  echo "$APP_PATH"
  echo ""
  echo "Skipped ad-hoc signing (--skip-sign). Sign manually before launching."
  exit 0
fi
echo "[5/5] Ad-hoc signing app bundle for local development..."
KDF_HELPER="$APP_PATH/Contents/Frameworks/komodo_defi_framework.framework/Versions/A/Helpers/kdf"
KDF_FRAMEWORK="$APP_PATH/Contents/Frameworks/komodo_defi_framework.framework"
if [ ! -d "$APP_PATH" ]; then
  echo "ERROR: expected app bundle not found at $APP_PATH" >&2
  exit 1
fi
if [ -e "$KDF_HELPER" ]; then
  codesign --force --sign - "$KDF_HELPER"
else
  echo "WARNING: KDF helper not found at $KDF_HELPER — signing bundle without it." >&2
fi
if [ -e "$KDF_FRAMEWORK" ]; then
  codesign --force --sign - "$KDF_FRAMEWORK"
else
  echo "WARNING: KDF framework not found at $KDF_FRAMEWORK — signing bundle without it." >&2
fi
codesign --deep --force --sign - "$APP_PATH"

if codesign --verify --deep --strict "$APP_PATH" 2>/dev/null; then
  echo ""
  echo "=== Build Complete! ==="
  echo "The native executable can be found at:"
  echo "$APP_PATH"
  echo ""
  echo "NOTE: the '** BUILD FAILED **' CodeSign error during step 4 is expected —"
  echo "the KDF install script copies the framework after Xcode signs, and step 5"
  echo "repairs the signature. The bundle above is valid."
else
  echo "" >&2
  echo "=== Build FAILED: signature verification did not pass ===" >&2
  exit 1
fi
