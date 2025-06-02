#!/usr/bin/env bash

# Print environment variables for debugging
set -ex
pwd
env | sort | grep -E "(APPLE_|APP_|XCODE_|GITHUB_)" # Filter sensitive info
xcodebuild -version