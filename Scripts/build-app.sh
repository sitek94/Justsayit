#!/bin/bash

set -ex

version="$(cat $VERSION_FILE)"
build_number="$GITHUB_RUN_NUMBER"

# Create archive
xcodebuild -project "$APP_NAME.xcodeproj" -scheme "$APP_NAME" \
  -configuration Release \
  -archivePath "build/$APP_NAME.xcarchive" \
  archive \
  MARKETING_VERSION="$version" \
  CURRENT_PROJECT_VERSION="$build_number"

# Export the archive
xcodebuild -exportArchive \
  -archivePath "build/$APP_NAME.xcarchive" \
  -exportPath "$BUILD_DIR/$XCODE_BUILD_PATH" \
  -exportOptionsPlist Resources/ExportOptions.plist

# Verify the build
file "$BUILD_DIR/$XCODE_BUILD_PATH/$APP_NAME.app/Contents/MacOS/$APP_NAME"