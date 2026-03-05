import XCTest
@testable import SnapStudyPlay

final class SnapStudyPlayTests: XCTestCase {
    func testMultiplicationDetection() {
        let analyzer = AssignmentAnalyzer()
        let assignment = analyzer.analyze(text: "7 x 8 = ?")
        XCTAssertEqual(assignment.type, .math)
        XCTAssertEqual(assignment.answer, 56)
        XCTAssertTrue(assignment.options.contains(56))
    }

    func testAdditionDetection() {
        let analyzer = AssignmentAnalyzer()
        let assignment = analyzer.analyze(text: "12 + 9 = ?")
        XCTAssertEqual(assignment.type, .math)
        XCTAssertEqual(assignment.answer, 21)
        XCTAssertTrue(assignment.options.contains(21))
    }

    func testDivisionDetection() {
        let analyzer = AssignmentAnalyzer()
        let assignment = analyzer.analyze(text: "42 / 6 = ?")
        XCTAssertEqual(assignment.type, .math)
        XCTAssertEqual(assignment.answer, 7)
        XCTAssertTrue(assignment.options.contains(7))
    }

    func testSubtractionDetection() {
        let analyzer = AssignmentAnalyzer()
        let assignment = analyzer.analyze(text: "20 - 8 = ?")
        XCTAssertEqual(assignment.type, .math)
        XCTAssertEqual(assignment.answer, 12)
        XCTAssertTrue(assignment.options.contains(12))
    }

    func testNonIntegerDivisionFallsBackFromMathParser() {
        let analyzer = AssignmentAnalyzer()
        let assignment = analyzer.analyze(text: "10 / 3 = ?")
        XCTAssertNotEqual(assignment.type, .math)
    }

    func testVocabularyRoutesToWordHunter() {
        let analyzer = AssignmentAnalyzer()
        let engine = GameTemplateEngine()
        let assignment = analyzer.analyze(text: "Translate: curious")
        let game = engine.generate(from: assignment)

        XCTAssertEqual(assignment.type, .vocabulary)
        XCTAssertTrue([.wordHunter, .synonymSprint, .grammarGate].contains(game.engine))
        XCTAssertFalse(game.payload.question.isEmpty)
        XCTAssertFalse(assignment.intelligenceSignals.isEmpty)
    }

    func testStoryRoutesToStoryEscape() {
        let analyzer = AssignmentAnalyzer()
        let engine = GameTemplateEngine()
        let assignment = analyzer.analyze(text: "In this story chapter, the character opens a hidden room.")
        let game = engine.generate(from: assignment)

        XCTAssertEqual(assignment.type, .story)
        XCTAssertTrue([.storyEscape, .timelineQuest, .grammarGate].contains(game.engine))
        XCTAssertFalse(game.payload.question.isEmpty)
        XCTAssertTrue(assignment.aiSource.contains("Apple"))
    }

    func testScienceRoutesToMoleculeBuilder() {
        let analyzer = AssignmentAnalyzer()
        let engine = GameTemplateEngine()
        let assignment = analyzer.analyze(text: "In naturfag, explain what molecule is in water.")
        let game = engine.generate(from: assignment)

        XCTAssertEqual(assignment.type, .science)
        XCTAssertTrue([.moleculeBuilder, .ecosystemBalance].contains(game.engine))
        XCTAssertFalse(game.payload.question.isEmpty)
        XCTAssertGreaterThan(assignment.classificationConfidence, 0.25)
    }

    func testEngineRegistryProvidesTenEngines() {
        let engine = GameTemplateEngine()
        XCTAssertEqual(engine.engineCount(), 10)
    }

    func testGeneratedGameContainsBlueprint() {
        let analyzer = AssignmentAnalyzer()
        let engine = GameTemplateEngine()
        let assignment = analyzer.analyze(text: "7 x 9 = ?")
        let game = engine.generate(from: assignment)

        XCTAssertFalse(game.blueprint.templateId.isEmpty)
        XCTAssertGreaterThan(game.blueprint.rounds, 0)
        XCTAssertGreaterThan(game.blueprint.timeLimitSeconds, 0)
    }

    func testProgressionEngineSessionAndMasteryUpdate() {
        let analyzer = AssignmentAnalyzer()
        let progression = ProgressionEngine()
        let assignment = analyzer.analyze(text: "8 + 5 = ?")

        var progress = LearnerProgress.initial
        progress = progression.startSession(current: progress)
        XCTAssertEqual(progress.sessionsCompleted, 1)

        let updated = progression.observeScore(current: progress, score: 5, assignment: assignment)
        XCTAssertGreaterThan(updated.streak, 0)
        XCTAssertFalse(updated.mastery.isEmpty)
    }

    func testLowConfidenceFallsBackToStableEngine() {
        let engine = GameTemplateEngine()
        let assignment = Assignment(
            type: .unknown,
            rawText: "random short text",
            extractedQuestion: "Ukjent oppgave",
            options: [1, 2, 3],
            answer: 1,
            aiSource: "test",
            classificationConfidence: 0.1,
            intelligenceSignals: [],
            learningProfile: LearningProfile(
                subject: .mixed,
                competencies: [.readingComprehension],
                gradeBand: .grade4to6,
                difficulty: .intro
            )
        )

        let game = engine.generate(from: assignment, progress: .initial)
        XCTAssertEqual(game.engine, .wordHunter)
    }

    func testLearnerProgressStoreRoundtrip() {
        let suiteName = "SnapStudyPlayTests.ProgressStore"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        let store = LearnerProgressStore(defaults: defaults)

        let original = LearnerProgress(
            sessionsCompleted: 4,
            streak: 2,
            mastery: [.arithmeticFluency: 55, .translation: 20]
        )
        store.save(original)
        let restored = store.load()

        XCTAssertEqual(restored.sessionsCompleted, 4)
        XCTAssertEqual(restored.streak, 2)
        XCTAssertEqual(restored.mastery[.arithmeticFluency], 55)
        XCTAssertEqual(restored.mastery[.translation], 20)
    }
}
