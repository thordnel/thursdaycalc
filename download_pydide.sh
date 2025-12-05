#!/usr/bin/env bash
set -euo pipefail

# Change VERSION and URL to the exact release asset you want.
VERSION="0.21.3"
# NOTE: make sure this URL points to the actual release asset (binary .tar.bz2)
# You can get it by right-clicking the asset link in the GitHub release page and "Copy link address".
URL="https://github.com/pyodide/pyodide/releases/download/${VERSION}/pyodide-build-${VERSION}.tar.bz2"

OUT="pyodide_build_${VERSION}.tar.bz2"
TMP="${OUT}.downloading"

echo "Downloading Pyodide ${VERSION} -> ${OUT}"
echo "URL: ${URL}"

# -f: fail on 4xx/5xx, -L: follow redirects, --retry: retry transient errors, --retry-connrefused to handle connection resets
curl -fL --retry 5 --retry-delay 2 --retry-connrefused -o "${TMP}" "${URL}" || {
  echo "curl failed. Check the URL and network. Use curl -v to see details."
  rm -f "${TMP}"
  exit 1
}

# Basic sanity checks
if [ ! -s "${TMP}" ]; then
  echo "Download completed but file is empty."
  rm -f "${TMP}"
  exit 2
fi

# Quick file-type check (not foolproof)
if file "${TMP}" | grep -qi 'html\|text'; then
  echo "Downloaded file looks like HTML/text which suggests the asset URL is wrong or returned an HTML error page."
  echo "Saving to ${OUT}.inspect for debugging."
  mv "${TMP}" "${OUT}.inspect"
  echo "Run: head -n 50 ${OUT}.inspect"
  exit 3
fi

# Try to list tar contents to ensure it's a valid tar.bz2
if ! tar -tjf "${TMP}" > /dev/null 2>&1; then
  echo "Downloaded file is not a valid .tar.bz2 archive."
  mv "${TMP}" "${OUT}.bad"
  echo "Saved to ${OUT}.bad for inspection."
  exit 4
fi

# Extract archive
echo "Extracting..."
tar -xjf "${TMP}"
rm -f "${TMP}"
echo "Extraction finished."

# Validate expected folder exists
if [ ! -d "pyodide" ]; then
  echo "Warning: expected top-level 'pyodide/' directory not found after extraction."
  echo "Listing first 100 entries from the tar for debugging:"
  tar -tjf "${OUT}" | sed -n '1,100p'
  exit 5
fi

echo "Pyodide distribution is ready in ./pyodide/"