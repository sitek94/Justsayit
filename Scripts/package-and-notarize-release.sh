#!/bin/bash

set -exu

version="$(cat $VERSION_FILE)"
appFile="$APP_NAME.app"
zipName="$APP_NAME-$version.zip"
oldPwd="$PWD"

cd "$XCODE_BUILD_PATH"
ditto -c -k --keepParent "$appFile" "$zipName"

# request notarization
requestStatus=$(xcrun notarytool submit "$zipName" \
  --apple-id "$APPLE_ID" \
  --password "$APPLE_ID_PASSWORD" \
  --team-id "$APPLE_TEAM_ID" \
  --wait --timeout 15m 2>&1 |
  tee /dev/tty |
  awk -F ': ' '/  status:/ { print $2; }')

if [[ $requestStatus != "Accepted" ]]; then 
  echo "Notarization failed with status: $requestStatus"
  exit 1
fi

# staple build
xcrun stapler staple "$appFile"
ditto -c -k --keepParent "$appFile" "$zipName"