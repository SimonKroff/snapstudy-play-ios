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
        XCTAssertEqual(game.engine, .wordHunter)
        XCTAssertEqual(game.payload.question, "Finn riktig ord for: curious")
        XCTAssertFalse(assignment.intelligenceSignals.isEmpty)
    }

    func testStoryRoutesToStoryEscape() {
        let analyzer = AssignmentAnalyzer()
        let engine = GameTemplateEngine()
        let assignment = analyzer.analyze(text: "In this story chapter, the character opens a hidden room.")
        let game = engine.generate(from: assignment)

        XCTAssertEqual(assignment.type, .story)
        XCTAssertEqual(game.engine, .storyEscape)
        XCTAssertFalse(game.payload.question.isEmpty)
        XCTAssertTrue(assignment.aiSource.contains("Apple"))
    }

    func testScienceRoutesToMoleculeBuilder() {
        let analyzer = AssignmentAnalyzer()
        let engine = GameTemplateEngine()
        let assignment = analyzer.analyze(text: "In naturfag, explain what molecule is in water.")
        let game = engine.generate(from: assignment)

        XCTAssertEqual(assignment.type, .science)
        XCTAssertEqual(game.engine, .moleculeBuilder)
        XCTAssertEqual(game.payload.question, "Velg riktig molekylformel for vann")
        XCTAssertGreaterThan(assignment.classificationConfidence, 0.25)
    }
}
