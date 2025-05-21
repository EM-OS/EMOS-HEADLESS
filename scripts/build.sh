#!/bin/bash

set -e

# Paths relative to this script
cd "$(dirname "$0")"
rootdir="$(pwd)/.."
outdir="$rootdir/out"
workdir="$rootdir/work"
iso_label="EMOS"



echo "==> Building ISO..."
mkarchiso \
  -v \
  -w "$workdir" \
  -o "$outdir" \
  "$rootdir"

echo "✅ ISO build complete! Find it in: $outdir"
