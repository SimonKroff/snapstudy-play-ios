# Deploy Runbook (Isolated Setup)

## 1. GitHub (new repo)

```bash
cd /home/ai-node/snapstudy-play
./scripts/bootstrap_repo.sh snapstudy-play-ios SimonKroff
```

If repo does not exist yet, create `snapstudy-play-ios` first in GitHub.

## 2. Apple Developer / App Store Connect (new app only)

Create new app identity:

- App name: `SnapStudy Play`
- Bundle ID: `no.snapstudy.play`
- SKU: `SNAPSTUDYPLAY001`

Do not reuse bundle IDs from other projects.

## 3. Certificates and profiles

Create dedicated signing assets for `no.snapstudy.play`:

- iOS Distribution certificate
- App Store provisioning profile bound to `no.snapstudy.play`

## 4. Codemagic (new app config)

1. Connect `SimonKroff/snapstudy-play-ios`.
2. Use repository file `codemagic.yaml`.
3. Add secure env vars:
   - `APP_STORE_CONNECT_KEY_IDENTIFIER`
   - `APP_STORE_CONNECT_ISSUER_ID`
   - `APP_STORE_CONNECT_PRIVATE_KEY`
   - `APPLE_TEAM_ID`
4. Start workflow `ios-development`.
5. Optional but recommended: verify PR checks using `ios-pr-check`.

## 5. Verify isolation

- Build logs show bundle id `no.snapstudy.play` only.
- TestFlight upload appears under SnapStudy Play app entry.
- No profile/certificate from other apps is referenced.
