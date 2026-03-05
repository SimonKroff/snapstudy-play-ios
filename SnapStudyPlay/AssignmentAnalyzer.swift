import Foundation

struct AssignmentAnalyzer {
    private let classifier = AppleAssignmentClassifier()

    func analyze(text: String) -> Assignment {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if let math = parseSimpleArithmetic(trimmed) {
            return Assignment(
                type: .math,
                rawText: trimmed,
                extractedQuestion: math.question,
                options: math.options,
                answer: math.answer,
                aiSource: "Apple Vision + heuristic math parser",
                classificationConfidence: 0.99,
                intelligenceSignals: ["type=math", "path=deterministic-arithmetic"]
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
            classificationConfidence: cls.confidence,
            intelligenceSignals: cls.signals
        )
    }

    private func parseSimpleArithmetic(_ text: String) -> (question: String, options: [Int], answer: Int)? {
        let pattern = #"(\d+)\s*([+\-x\*/])\s*(\d+)"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return nil }
        let range = NSRange(location: 0, length: text.utf16.count)
        guard let match = regex.firstMatch(in: text, options: [], range: range),
              let lhsRange = Range(match.range(at: 1), in: text),
              let opRange = Range(match.range(at: 2), in: text),
              let rhsRange = Range(match.range(at: 3), in: text),
              let lhs = Int(text[lhsRange]),
              let rhs = Int(text[rhsRange]) else {
            return nil
        }

        let op = String(text[opRange])
        let normalizedOp = op == "*" ? "x" : op

        let answer: Int
        switch normalizedOp {
        case "+":
            answer = lhs + rhs
        case "-":
            answer = lhs - rhs
        case "x":
            answer = lhs * rhs
        case "/":
            guard rhs != 0, lhs % rhs == 0 else { return nil }
            answer = lhs / rhs
        default:
            return nil
        }

        return ("\(lhs) \(normalizedOp) \(rhs) = ?", buildMathOptions(answer: answer), answer)
    }

    private func buildMathOptions(answer: Int) -> [Int] {
        let offsets = [-3, -2, -1, 1, 2, 3, 4, -4]
        var options = [answer]
        for offset in offsets {
            let candidate = answer + offset
            if candidate >= 0, !options.contains(candidate) {
                options.append(candidate)
            }
            if options.count == 3 { break }
        }
        while options.count < 3 {
            options.append(answer + options.count)
        }
        return options.shuffled()
    }

    private func fallbackPayload(for type: AssignmentType, text: String) -> (String, [Int], Int) {
        switch type {
        case .vocabulary:
            let prompt = extractVocabularyPrompt(from: text)
            return (prompt, [1, 2, 3, 4], 1)
        case .story:
            return (extractStoryPrompt(from: text), [1, 2, 3], 1)
        case .science:
            return (extractSciencePrompt(from: text), [1, 2, 3], 1)
        case .unknown, .math:
            return (text.isEmpty ? "Ukjent oppgave" : text, [1, 2, 3], 1)
        }
    }

    private func extractVocabularyPrompt(from text: String) -> String {
        let lowered = text.lowercased()
        let markers = ["translate", "oversett", "meaning of", "betyr", "define"]

        for marker in markers {
            guard let range = lowered.range(of: marker) else { continue }
            let originalSlice = text[range.upperBound...]
            let cleaned = originalSlice
                .replacingOccurrences(of: ":", with: "")
                .replacingOccurrences(of: "\"", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)

            if let firstWord = cleaned.split(whereSeparator: { $0.isWhitespace || $0.isPunctuation }).first,
               firstWord.count >= 2 {
                return "Finn riktig ord for: \(firstWord)"
            }
        }

        return "Finn riktig oversettelse"
    }

    private func extractStoryPrompt(from text: String) -> String {
        let lowered = text.lowercased()
        if lowered.contains("chapter") || lowered.contains("kapittel") {
            return "Velg hendelsen som passer best til kapitlet"
        }
        if lowered.contains("character") || lowered.contains("karakter") || lowered.contains("person") {
            return "Hvilken handling passer hovedpersonen?"
        }
        return "Hvilken hendelse låser døren opp?"
    }

    private func extractSciencePrompt(from text: String) -> String {
        let lowered = text.lowercased()
        if lowered.contains("water") || lowered.contains("vann") {
            return "Velg riktig molekylformel for vann"
        }
        if lowered.contains("oxygen") || lowered.contains("oksygen") {
            return "Velg riktig molekylformel for oksygen"
        }
        if lowered.contains("co2") || lowered.contains("karbondioksid") {
            return "Velg riktig molekylformel for karbondioksid"
        }
        return "Bygg korrekt molekylstruktur"
    }
}
