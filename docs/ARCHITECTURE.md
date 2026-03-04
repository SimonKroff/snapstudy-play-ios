# SnapStudy Play Architecture

## Core modules

- `VisionOCRService`: OCR from camera image using Apple Vision.
- `AppleAssignmentClassifier`: assignment-type classification using Apple NaturalLanguage.
- `AssignmentAnalyzer`: combines parser + classifier and extracts challenge data.
- `GameTemplateEngine`: maps assignment into one of a small set of game engines.
- `GameRuntime`: receives `GeneratedGame` and launches SpriteKit/SwiftUI gameplay.

## Assignment types

- `math`
- `vocabulary`
- `story`
- `science`
- `unknown`

## Game engines (initial)

- `mathDash`: run/jump through answer gates
- `wordHunter`: shoot correct translation targets
- `storyEscape`: unlock doors based on story comprehension
- `moleculeBuilder`: bubble-shooter style chemistry builder

## Why template engines over full generation

Real-time generation is safer and faster when constrained to 5-10 proven engines.
The AI generates level/config data, not executable code.

## Apple AI baseline

- On-device OCR: Vision framework
- On-device text understanding: NaturalLanguage framework
- Optional model extension: CoreML custom classifier (future)
