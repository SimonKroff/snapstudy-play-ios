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

    func testVocabularyRoutesToWordHunter() {
        let analyzer = AssignmentAnalyzer()
        let engine = GameTemplateEngine()
        let assignment = analyzer.analyze(text: "Translate: curious")
        let game = engine.generate(from: assignment)

        XCTAssertEqual(assignment.type, .vocabulary)
        XCTAssertEqual(game.engine, .wordHunter)
        XCTAssertEqual(game.payload.question, "Finn riktig ord for: curious")
    }

    func testStoryRoutesToStoryEscape() {
        let analyzer = AssignmentAnalyzer()
        let engine = GameTemplateEngine()
        let assignment = analyzer.analyze(text: "In this story chapter, the character opens a hidden room.")
        let game = engine.generate(from: assignment)

        XCTAssertEqual(assignment.type, .story)
        XCTAssertEqual(game.engine, .storyEscape)
        XCTAssertFalse(game.payload.question.isEmpty)
    }

    func testScienceRoutesToMoleculeBuilder() {
        let analyzer = AssignmentAnalyzer()
        let engine = GameTemplateEngine()
        let assignment = analyzer.analyze(text: "In naturfag, explain what molecule is in water.")
        let game = engine.generate(from: assignment)

        XCTAssertEqual(assignment.type, .science)
        XCTAssertEqual(game.engine, .moleculeBuilder)
        XCTAssertEqual(game.payload.question, "Velg riktig molekylformel for vann")
    }
}
