#!/bin/bash

# Setup certificate

echo "$APPLE_CERTIFICATE_BASE64" | base64 --decode > certificate.p12
security create-keychain -p temp build.keychain
security default-keychain -s build.keychain
security unlock-keychain -p temp build.keychain
security import certificate.p12 -k build.keychain -P "$APPLE_CERTIFICATE_PASSWORD" -T /usr/bin/codesign
security set-key-partition-list -S apple-tool:,apple:,codesign: -s -k temp build.keychain
