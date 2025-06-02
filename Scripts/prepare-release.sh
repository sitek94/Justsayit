#!/bin/bash

set -exu

version="$(cat $VERSION_FILE)"

# Configure git
git config user.name "github-actions[bot]"
git config user.email "github-actions[bot]@users.noreply.github.com"

# Commit appcast changes
git add appcast.xml
git commit -m "release v$version [skip ci]" || exit 0
git push