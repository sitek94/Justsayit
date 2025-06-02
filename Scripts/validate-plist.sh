#!/bin/bash

# Build script to validate required Info.plist keys

set -e

echo "🔍 Validating Info.plist..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INFOPLIST_FILE="${1:-$SCRIPT_DIR/../Resources/Info.plist}"

if [ ! -f "$INFOPLIST_FILE" ]; then
  echo "❌ Info.plist file not found at: $INFOPLIST_FILE"
  exit 1
fi

if ! plutil -lint "$INFOPLIST_FILE"; then
  echo "❌ Info.plist syntax error."
  exit 1
fi

REQUIRED_KEYS=(
  # Microphone access
  "NSMicrophoneUsageDescription"

  # Auto-update - required by Sparkle
  "SUEnableInstallerLauncherService"
  "SUEnableAutomaticChecks"
  "SUFeedURL"
  "SUPublicEDKey"

  # Add more keys here
)

FAILED=()

for key in "${REQUIRED_KEYS[@]}"; do
  # Check if the key exists in the Info.plist file
  if ! /usr/libexec/PlistBuddy -c "Print $key" "$INFOPLIST_FILE" >/dev/null 2>&1; then
      FAILED+=("$key")
  fi
done


# If any keys are missing, exit with an error
if [ ${#FAILED[@]} -gt 0 ]; then
  echo "❌ Missing Info.plist keys:"
  for key in "${FAILED[@]}"; do
      echo "  • $key"
  done
  exit 1
fi

echo "✅ Info.plist validation passed" 