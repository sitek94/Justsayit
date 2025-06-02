#!/bin/bash

set -ex

version="$(cat $VERSION_FILE)"
build_number="$GITHUB_RUN_NUMBER"

# Create archive
xcodebuild -project LearningSwift.xcodeproj -scheme LearningSwift \
  -configuration Release \
  -archivePath build/LearningSwift.xcarchive \
  archive \
  MARKETING_VERSION="$version" \
  CURRENT_PROJECT_VERSION="$build_number"

# Export the archive
xcodebuild -exportArchive \
  -archivePath build/LearningSwift.xcarchive \
  -exportPath "$BUILD_DIR/$XCODE_BUILD_PATH" \
  -exportOptionsPlist Scripts/ExportOptions.plist

# Verify the build
file "$BUILD_DIR/$XCODE_BUILD_PATH/$APP_NAME.app/Contents/MacOS/$APP_NAME"