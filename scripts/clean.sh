#!/bin/bash

# Navigate to the script directory
cd "$(dirname "$0")"
rootdir="$(pwd)/.."

echo "==> Cleaning build directories..."

rm -Rf "$rootdir/out"
rm -Rf "$rootdir/work"

echo "✅ Cleaned: out/ and work/ directories."
