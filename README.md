# SnapStudy Play

Homework -> Game Engine for iOS, built with Apple on-device AI from day one.

## What is included

- OCR pipeline skeleton (`VisionOCRService`, Apple Vision)
- Assignment analyzer (`AssignmentAnalyzer` + `AppleAssignmentClassifier`, Apple NaturalLanguage)
- Game template engine (`GameTemplateEngine`)
- First playable mini-game: `MathDashScene` (SpriteKit)
- Performance prototype: high score can unlock a fictional Steam discount card placeholder
- XcodeGen setup via `project.yml`
- Codemagic CI/TestFlight via `codemagic.yaml`
- Isolation checklist for separate repo/app/cert setup

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
