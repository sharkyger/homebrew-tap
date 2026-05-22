#!/bin/bash
# release-safe-fetch.sh — drive the tap update after a new safe-fetch tag.
#
# Workflow:
#   1. In ~/Projects/public/safe-fetch:
#        git tag -s vX.Y.Z -m "vX.Y.Z"
#        git push origin vX.Y.Z
#   2. In ~/Projects/public/homebrew-tap:
#        bin/release-safe-fetch.sh vX.Y.Z
#   3. Commit + push the resulting Formula/safe-fetch.rb diff.
#
# This script:
#   - Downloads the GitHub tarball for the tag
#   - Computes its sha256
#   - Updates the url + sha256 in Formula/safe-fetch.rb
#   - Optionally runs `brew update-python-resources` if Homebrew is available

set -euo pipefail

TAG="${1:?Usage: release-safe-fetch.sh vX.Y.Z}"
TARBALL_URL="https://github.com/sharkyger/safe-fetch/archive/refs/tags/${TAG}.tar.gz"
FORMULA="$(cd "$(dirname "$0")/.." && pwd)/Formula/safe-fetch.rb"

echo "Downloading ${TARBALL_URL}"
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

curl -fsSL "$TARBALL_URL" -o "$TMP/safe-fetch.tar.gz"
SHA=$(shasum -a 256 "$TMP/safe-fetch.tar.gz" | awk '{print $1}')
echo "sha256: $SHA"

# Update url + sha256 in the formula.
sed -i.bak -E \
  -e "s|^  url \".*\"$|  url \"${TARBALL_URL}\"|" \
  -e "s|^  sha256 \".*\"$|  sha256 \"${SHA}\"|" \
  "$FORMULA"
rm -f "${FORMULA}.bak"

echo "Updated ${FORMULA} for ${TAG}"
echo
echo "Next:"
echo "  brew update-python-resources ${FORMULA}   # optional, refreshes PyPI pins"
echo "  git -C $(dirname "${FORMULA}")/.. add Formula/safe-fetch.rb"
echo "  git commit -m 'safe-fetch ${TAG}'"
echo "  git push origin main"
