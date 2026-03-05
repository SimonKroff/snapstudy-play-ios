# Separate Setup Checklist (No App Mixing)

Use this list for a clean isolated product setup.

1. Create a new GitHub repository (example: `snapstudy-play-ios`) under your owner.
2. Create a new App Store Connect app with unique bundle id: `no.snapstudy.play`.
3. Create a dedicated iOS distribution certificate/profile for this bundle id.
4. Create a dedicated Codemagic app connected to this new repository.
5. Add only project-specific environment variables in Codemagic:
   - `APP_STORE_CONNECT_KEY_IDENTIFIER`
   - `APP_STORE_CONNECT_ISSUER_ID`
   - `APP_STORE_CONNECT_PRIVATE_KEY`
   - `APPLE_TEAM_ID`
6. Confirm workflow signs only `no.snapstudy.play`.
7. Set branch protection and deploy from `main` only.
8. Verify TestFlight uploads appear on the new app entry, not existing apps.
9. Run `./scripts/verify_isolation.sh` before each release/build trigger.
