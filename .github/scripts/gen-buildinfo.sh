#!/usr/bin/env bash

set -eu

# Generate a .BUILDINFO file for reproducible builds:
cat <<EOF > .BUILDINFO
SOURCE_COMMIT = "$GITHUB_SHA"
SOURCE_DATE = "$(date --date=@$(git log -1 --pretty='%ct') +'%F')"
BUILD_DATE = "$(date --utc +'%F')"
NIXPKGS_COMMIT = "$NIXPKGS_COMMIT"
EOF
