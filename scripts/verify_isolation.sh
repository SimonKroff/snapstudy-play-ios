#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

EXPECTED_REPO="snapstudy-play-ios"
EXPECTED_BUNDLE="no.snapstudy.play"
EXPECTED_TEST_BUNDLE="no.snapstudy.play.tests"

echo "[1/5] Checking git remote name/url"
REMOTE_URL="$(git remote get-url origin 2>/dev/null || true)"
if [[ -z "$REMOTE_URL" ]]; then
  echo "ERROR: origin remote is missing."
  exit 1
fi
if [[ "$REMOTE_URL" != *"$EXPECTED_REPO"* ]]; then
  echo "ERROR: origin remote does not target $EXPECTED_REPO"
  echo "Remote: $REMOTE_URL"
  exit 1
fi

echo "[2/5] Checking bundle identifiers in project.yml"
if ! rg -n "PRODUCT_BUNDLE_IDENTIFIER: ${EXPECTED_BUNDLE}$" project.yml >/dev/null; then
  echo "ERROR: App bundle id mismatch in project.yml"
  exit 1
fi
if ! rg -n "PRODUCT_BUNDLE_IDENTIFIER: ${EXPECTED_TEST_BUNDLE}$" project.yml >/dev/null; then
  echo "ERROR: Test bundle id mismatch in project.yml"
  exit 1
fi

echo "[3/5] Checking Codemagic bundle and signing references"
if ! rg -n "BUNDLE_ID: \"${EXPECTED_BUNDLE}\"" codemagic.yaml >/dev/null; then
  echo "ERROR: Codemagic BUNDLE_ID mismatch."
  exit 1
fi
if ! rg -n "APP_STORE_CONNECT_KEY_IDENTIFIER|APP_STORE_CONNECT_ISSUER_ID|APP_STORE_CONNECT_PRIVATE_KEY|APPLE_TEAM_ID" codemagic.yaml >/dev/null; then
  echo "ERROR: Expected Codemagic signing variables not found."
  exit 1
fi

echo "[4/5] Scanning for known cross-app leakage markers"
if rg -n --glob '!scripts/verify_isolation.sh' "(com\\.spillo|urban-paw|spillo-games|no\\.spillo)" README.md docs project.yml codemagic.yaml SnapStudyPlay scripts >/dev/null; then
  echo "ERROR: Found references that appear to belong to another app."
  rg -n --glob '!scripts/verify_isolation.sh' "(com\\.spillo|urban-paw|spillo-games|no\\.spillo)" README.md docs project.yml codemagic.yaml SnapStudyPlay scripts
  exit 1
fi

echo "[5/5] Checking for committed secrets patterns"
if rg -n --glob '!scripts/verify_isolation.sh' "(github_pat_|-----BEGIN PRIVATE KEY-----|AKts[[:alnum:]]{20,}|APP_STORE_CONNECT_PRIVATE_KEY\\s*=\\s*\\()" . >/dev/null; then
  echo "ERROR: Potential secret material found in repository files."
  rg -n --glob '!scripts/verify_isolation.sh' "(github_pat_|-----BEGIN PRIVATE KEY-----|AKts[[:alnum:]]{20,}|APP_STORE_CONNECT_PRIVATE_KEY\\s*=\\s*\\()" .
  exit 1
fi

echo "Isolation check passed."
