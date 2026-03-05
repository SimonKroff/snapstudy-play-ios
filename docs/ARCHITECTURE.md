# SnapStudy Play Architecture

## Core modules

- `VisionOCRService`: OCR from camera image using Apple Vision.
- `AppleAssignmentClassifier`: assignment-type classification using Apple NaturalLanguage.
  - Hybrid signals: token overlap, lemma overlap, sentence embeddings, and named-entity hints.
- `AssignmentAnalyzer`: combines parser + classifier and extracts challenge data.
- `EngineRegistry`: catalog of engine capabilities + template schema per engine.
- `GameTemplateEngine`: maps assignment into one of 10 engines and generates `GameBlueprint`.
- `ProgressionEngine`: computes recommended difficulty and tracks mastery progression.
- `GameRuntime`: receives `GeneratedGame` and launches SpriteKit/SwiftUI gameplay.

## Assignment types

- `math`
- `vocabulary`
- `story`
- `science`
- `unknown`

## Game engines (batch-1)

- `mathDash`: run/jump through answer gates
- `equationBuilder`: solve equation patterns via options
- `fractionForge`: compare/select fraction outcomes
- `wordHunter`: shoot correct translation targets
- `synonymSprint`: pick contextual synonyms
- `grammarGate`: choose grammatically correct sentence
- `storyEscape`: unlock doors based on story comprehension
- `timelineQuest`: sequence historical/story events
- `moleculeBuilder`: bubble-shooter style chemistry builder
- `ecosystemBalance`: classify food-chain/ecosystem roles

## Why template engines over full generation

Real-time generation is safer and faster when constrained to 5-10 proven engines.
The AI generates level/config data, not executable code.

## Apple AI baseline

- On-device OCR: Vision framework
- On-device text understanding: NaturalLanguage framework
- Optional model extension: CoreML custom classifier (future)
