#!/usr/bin/env bash
set -euo pipefail

REPO_NAME="${1:-snapstudy-play-ios}"
OWNER="${2:-SimonKroff}"

echo "1/4 Generating Xcode project"
xcodegen generate --spec project.yml

echo "2/4 Initializing git"
git init
git add .
git commit -m "Initial SnapStudy Play scaffold"

echo "3/4 Add remote (create repository first in GitHub UI or gh CLI)"
git remote add origin "git@github.com:${OWNER}/${REPO_NAME}.git"

echo "4/4 Push main"
git branch -M main
git push -u origin main

echo "Done. Connect ${OWNER}/${REPO_NAME} in Codemagic."
