import SwiftUI
import SpriteKit
import PhotosUI
import UIKit

struct ContentView: View {
    @State private var homeworkText = ""
    @State private var generatedGame: GeneratedGame?
    @State private var analyzedAssignment: Assignment?
    @State private var prototypeScore = 0
    @State private var activeScene: SKScene?
    @State private var learnerProgress = LearnerProgress.initial
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var isExtractingText = false
    @State private var ocrStatusMessage: String?
    @State private var isShowingCamera = false
    @State private var capturedImage: UIImage?

    private let analyzer = AssignmentAnalyzer()
    private let engine = GameTemplateEngine()
    private let achievementEngine = AchievementEngine()
    private let progressionEngine = ProgressionEngine()
    private let ocrService = VisionOCRService()

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

                HStack(spacing: 12) {
                    PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                        Label(isExtractingText ? "Leser bilde..." : "Velg Bilde (OCR)", systemImage: "photo.on.rectangle")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .disabled(isExtractingText)

                    Button {
                        isShowingCamera = true
                    } label: {
                        Label("Ta Bilde", systemImage: "camera")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .disabled(isExtractingText || !UIImagePickerController.isSourceTypeAvailable(.camera))

                    Button("Tøm") {
                        homeworkText = ""
                        ocrStatusMessage = nil
                    }
                    .buttonStyle(.bordered)
                }

                if let ocrStatusMessage {
                    Text(ocrStatusMessage)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Button("Generate Game") {
                    let assignment = analyzer.analyze(text: homeworkText)
                    let game = engine.generate(from: assignment, progress: learnerProgress)

                    analyzedAssignment = assignment
                    generatedGame = game
                    prototypeScore = 0
                    learnerProgress = progressionEngine.startSession(current: learnerProgress)

                    let scoreBinding = $prototypeScore
                    let rawText = assignment.rawText.isEmpty ? game.payload.question : assignment.rawText
                    let scoreUpdater: (Int) -> Void = { score in
                        DispatchQueue.main.async {
                            scoreBinding.wrappedValue = score
                            learnerProgress = progressionEngine.observeScore(current: learnerProgress, score: score, assignment: assignment)
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
                    case .equationBuilder, .fractionForge, .synonymSprint, .grammarGate, .timelineQuest, .ecosystemBalance:
                        let textOptions = game.payload.textOptions.isEmpty ? ["A", "B", "C", "D"] : game.payload.textOptions
                        let correctText = game.payload.correctText ?? textOptions.first ?? "A"
                        activeScene = TemplateArenaScene(
                            prompt: game.payload.question,
                            options: textOptions,
                            correct: correctText,
                            onScoreChanged: scoreUpdater
                        )
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(homeworkText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isExtractingText)

                if let game = generatedGame {
                    Text("Engine: \(game.engine.rawValue)")
                        .font(.headline)
                    Text(game.title)
                        .foregroundStyle(.secondary)
                    Text("AI: \(analyzedAssignment?.aiSource ?? "Apple on-device")")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("Confidence: \(Int((analyzedAssignment?.classificationConfidence ?? 0) * 100))%")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    if let profile = analyzedAssignment?.learningProfile {
                        Text("Subject: \(profile.subject.rawValue) | Grade: \(profile.gradeBand.rawValue) | Difficulty: \(profile.difficulty.rawValue)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    if let signals = analyzedAssignment?.intelligenceSignals, !signals.isEmpty {
                        Text("Signals: \(signals.joined(separator: " | "))")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    if let blueprint = generatedGame?.blueprint {
                        Text("Blueprint: \(blueprint.templateId) | rounds=\(blueprint.rounds) | time=\(blueprint.timeLimitSeconds)s")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }

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
                        Text("Sessions: \(learnerProgress.sessionsCompleted) | Streak: \(learnerProgress.streak)")
                            .font(.caption)
                            .foregroundStyle(.secondary)

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
        .task(id: selectedPhotoItem) {
            await extractTextFromSelectedPhoto()
        }
        .onChange(of: capturedImage) { _, newImage in
            guard let newImage else { return }
            Task {
                await extractText(from: newImage)
            }
        }
        .sheet(isPresented: $isShowingCamera) {
            CameraImagePicker(image: $capturedImage)
        }
    }

    private func runOCR(on image: UIImage) async -> String {
        await withCheckedContinuation { continuation in
            ocrService.extractText(from: image) { text in
                continuation.resume(returning: text)
            }
        }
    }

    private func extractTextFromSelectedPhoto() async {
        guard let item = selectedPhotoItem else { return }

        do {
            guard let data = try await item.loadTransferable(type: Data.self),
                  let image = UIImage(data: data) else {
                await MainActor.run {
                    ocrStatusMessage = "Kunne ikke lese valgt bilde."
                }
                return
            }

            await extractText(from: image)
        } catch {
            await MainActor.run {
                ocrStatusMessage = "OCR feilet: \(error.localizedDescription)"
            }
        }
    }

    private func extractText(from image: UIImage) async {
        await MainActor.run {
            isExtractingText = true
            ocrStatusMessage = "Analyserer bilde med Vision OCR..."
        }

        let extractedText = await runOCR(on: image)
        await MainActor.run {
            isExtractingText = false
            if extractedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                ocrStatusMessage = "Fant ingen tekst i bildet."
            } else {
                homeworkText = extractedText
                ocrStatusMessage = "OCR ferdig. \(extractedText.count) tegn hentet."
            }
        }
    }
}
