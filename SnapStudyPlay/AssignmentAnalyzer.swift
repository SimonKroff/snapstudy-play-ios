import Foundation

struct AssignmentAnalyzer {
    private let classifier = AppleAssignmentClassifier()

    func analyze(text: String) -> Assignment {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if let math = parseSimpleMultiplication(trimmed) {
            return Assignment(
                type: .math,
                rawText: trimmed,
                extractedQuestion: math.question,
                options: math.options,
                answer: math.answer,
                aiSource: "Apple Vision + heuristic math parser",
                classificationConfidence: 0.99
            )
        }

        let cls = classifier.classify(text: trimmed)
        let (question, options, answer) = fallbackPayload(for: cls.type, text: trimmed)
        return Assignment(
            type: cls.type,
            rawText: trimmed,
            extractedQuestion: question,
            options: options,
            answer: answer,
            aiSource: cls.source,
            classificationConfidence: cls.confidence
        )
    }

    private func parseSimpleMultiplication(_ text: String) -> (question: String, options: [Int], answer: Int)? {
        let pattern = #"(\d+)\s*[x\*]\s*(\d+)"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return nil }
        let range = NSRange(location: 0, length: text.utf16.count)
        guard let match = regex.firstMatch(in: text, options: [], range: range),
              let lhsRange = Range(match.range(at: 1), in: text),
              let rhsRange = Range(match.range(at: 2), in: text),
              let lhs = Int(text[lhsRange]),
              let rhs = Int(text[rhsRange]) else {
            return nil
        }

        let answer = lhs * rhs
        let options = [answer - 2, answer, answer + 3].shuffled()
        return ("\(lhs) x \(rhs) = ?", options, answer)
    }

    private func fallbackPayload(for type: AssignmentType, text: String) -> (String, [Int], Int) {
        switch type {
        case .vocabulary:
            return ("Find riktig oversettelse", [1, 2, 3], 1)
        case .story:
            return ("Hvilken hendelse låser døren opp?", [1, 2, 3], 1)
        case .science:
            return ("Bygg korrekt molekylstruktur", [1, 2, 3], 1)
        case .unknown, .math:
            return (text.isEmpty ? "Ukjent oppgave" : text, [1, 2, 3], 1)
        }
    }
}
