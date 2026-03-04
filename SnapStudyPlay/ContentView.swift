import SwiftUI
import SpriteKit

struct ContentView: View {
    @State private var homeworkText = ""
    @State private var generatedGame: GeneratedGame?
    @State private var analyzedAssignment: Assignment?
    @State private var prototypeScore = 0
    @State private var activeScene: SKScene?

    private let analyzer = AssignmentAnalyzer()
    private let engine = GameTemplateEngine()
    private let achievementEngine = AchievementEngine()

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("SnapStudy Play")
                    .font(.largeTitle.bold())

                Text("Paste homework text (OCR output) to generate a real mini-game.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                TextEditor(text: $homeworkText)
                    .frame(minHeight: 180)
                    .padding(8)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(.gray.opacity(0.35), lineWidth: 1))

                Button("Generate Game") {
                    let assignment = analyzer.analyze(text: homeworkText)
                    let game = engine.generate(from: assignment)

                    analyzedAssignment = assignment
                    generatedGame = game
                    prototypeScore = 0

                    let scoreBinding = $prototypeScore
                    let rawText = assignment.rawText.isEmpty ? game.payload.question : assignment.rawText
                    let scoreUpdater: (Int) -> Void = { score in
                        DispatchQueue.main.async {
                            scoreBinding.wrappedValue = score
                        }
                    }

                    switch game.engine {
                    case .mathDash:
                        activeScene = MathDashScene(
                            question: game.payload.question,
                            options: game.payload.options,
                            correctAnswer: game.payload.correctAnswer,
                            onScoreChanged: scoreUpdater
                        )
                    case .wordHunter:
                        activeScene = WordHunterScene(
                            prompt: game.payload.question,
                            sourceText: rawText,
                            onScoreChanged: scoreUpdater
                        )
                    case .storyEscape:
                        activeScene = StoryEscapeScene(
                            prompt: game.payload.question,
                            sourceText: rawText,
                            onScoreChanged: scoreUpdater
                        )
                    case .moleculeBuilder:
                        activeScene = MoleculeBuilderScene(
                            prompt: game.payload.question,
                            sourceText: rawText,
                            onScoreChanged: scoreUpdater
                        )
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(homeworkText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

                if let game = generatedGame {
                    Text("Engine: \(game.engine.rawValue)")
                        .font(.headline)
                    Text(game.title)
                        .foregroundStyle(.secondary)
                    Text("AI: \(analyzedAssignment?.aiSource ?? \"Apple on-device\")")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("Confidence: \(Int((analyzedAssignment?.classificationConfidence ?? 0) * 100))%")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    if let scene = activeScene {
                        SpriteView(scene: scene)
                            .frame(height: 320)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    } else {
                        Text("Prototype created. Gameplay scene for \(game.engine.rawValue) is next.")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(.blue.opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    let reward = achievementEngine.evaluate(score: prototypeScore)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Performance Prototype")
                            .font(.headline)
                        Text("Live score: \(prototypeScore)")
                            .font(.subheadline)

                        Text(reward.title)
                            .font(.subheadline.bold())
                        Text(reward.description)
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Text("Unlock score: \(reward.minimumScore)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(reward.unlocked ? .green.opacity(0.14) : .orange.opacity(0.14))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Homework -> Game")
        }
    }
}
