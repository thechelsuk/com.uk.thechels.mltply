#!/bin/sh
# Xcode Cloud: fail fast if a tag build's version doesn't match the project.
# The GitHub release workflow writes MARKETING_VERSION and then creates the
# tag, so the two must agree. Branch and PR builds are not checked.
set -e

[ -z "$CI_TAG" ] && exit 0

VERSION="${CI_TAG#v}"
if ! echo "$VERSION" | grep -Eq '^[0-9]{6}\.[0-9]+$'; then
  echo "error: tag $CI_TAG is not a valid vYYYYMM.N version"
  exit 1
fi

cd "$(dirname "$0")/.."
PBXPROJ=$(ls -d *.xcodeproj | head -1)/project.pbxproj
FOUND=$(grep -oE 'MARKETING_VERSION = [^;]+' "$PBXPROJ" | sed 's/MARKETING_VERSION = //' | sort -u)

if [ "$FOUND" != "$VERSION" ]; then
  echo "error: tag $CI_TAG but project MARKETING_VERSION is: $FOUND"
  exit 1
fi
echo "Version $VERSION matches tag $CI_TAG"
