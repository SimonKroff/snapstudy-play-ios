# SnapStudy Play

Homework -> Game Engine for iOS, built with Apple on-device AI from day one.

## What is included

- OCR pipeline skeleton (`VisionOCRService`, Apple Vision)
- UI flow for OCR from selected photo/camera (`PhotosPicker`/camera -> `VisionOCRService`)
- Assignment analyzer (`AssignmentAnalyzer` + `AppleAssignmentClassifier`, Apple NaturalLanguage hybrid: keywords + lemmas + embeddings + entity tags)
- Game template engine (`GameTemplateEngine`)
- Playable mini-games: `MathDashScene`, `WordHunterScene`, `StoryEscapeScene`, `MoleculeBuilderScene` (SpriteKit)
- Performance prototype: high score can unlock a fictional Steam discount card placeholder
- XcodeGen setup via `project.yml`
- Codemagic CI/TestFlight via `codemagic.yaml`
- Isolation checklist for separate repo/app/cert setup

## CI/CD (GitHub + Codemagic)

- PRs in GitHub trigger `ios-pr-check` in Codemagic (generate project + run tests).
- Push to `main` triggers `ios-development` in Codemagic (signed release build + TestFlight upload).
- Keep all signing/API secrets only in Codemagic secure environment variables.

## Local run

```bash
brew install xcodegen
xcodegen generate --spec project.yml
xcodebuild -project SnapStudyPlay.xcodeproj -scheme SnapStudyPlay -destination 'platform=iOS Simulator,name=iPhone 16' clean test
```

## Security

Never commit App Store Connect keys, Codemagic API keys, or GitHub PAT tokens.
Use secure environment variables in Codemagic and GitHub.
The Steam reward card is currently fictional/non-redeemable and used only for product prototyping.

## Architecture flow

1. Capture homework image
2. Extract text with Apple Vision OCR
3. Detect assignment type with Apple NaturalLanguage
4. Generate game config
5. Launch mapped game scene

See [docs/ARCHITECTURE.md](/home/ai-node/snapstudy-play/docs/ARCHITECTURE.md).
