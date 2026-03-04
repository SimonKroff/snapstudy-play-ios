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
}
