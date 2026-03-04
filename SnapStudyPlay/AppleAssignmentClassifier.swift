import Foundation
import NaturalLanguage

struct AssignmentClassification {
    let type: AssignmentType
    let confidence: Double
    let source: String
}

struct AppleAssignmentClassifier {
    func classify(text: String) -> AssignmentClassification {
        let lowered = text.lowercased()
        let tokens = tokenize(lowered)

        let vocabularyWords: Set<String> = ["translate", "oversett", "gloser", "vocabulary", "meaning", "ordliste"]
        let storyWords: Set<String> = ["story", "chapter", "character", "historie", "tekst", "handling", "forfatter"]
        let scienceWords: Set<String> = ["molecule", "atom", "periodic", "naturfag", "kjemi", "fysikk", "biologi"]

        let vocabScore = overlapScore(tokens: tokens, keywords: vocabularyWords)
        let storyScore = overlapScore(tokens: tokens, keywords: storyWords)
        let scienceScore = overlapScore(tokens: tokens, keywords: scienceWords)

        let recognizer = NLLanguageRecognizer()
        recognizer.processString(text)
        let langConfidence = recognizer.languageHypotheses(withMaximum: 1).values.first ?? 0.5

        let weightedVocab = vocabScore * 0.8 + langConfidence * 0.2
        let weightedStory = storyScore * 0.8 + langConfidence * 0.2
        let weightedScience = scienceScore * 0.8 + langConfidence * 0.2

        let maxScore = max(weightedVocab, weightedStory, weightedScience)

        if maxScore < 0.26 {
            return AssignmentClassification(type: .unknown, confidence: maxScore, source: "Apple NaturalLanguage keyword classifier")
        }

        if weightedVocab >= weightedStory && weightedVocab >= weightedScience {
            return AssignmentClassification(type: .vocabulary, confidence: weightedVocab, source: "Apple NaturalLanguage keyword classifier")
        }

        if weightedStory >= weightedScience {
            return AssignmentClassification(type: .story, confidence: weightedStory, source: "Apple NaturalLanguage keyword classifier")
        }

        return AssignmentClassification(type: .science, confidence: weightedScience, source: "Apple NaturalLanguage keyword classifier")
    }

    private func tokenize(_ text: String) -> Set<String> {
        var words: [String] = []
        let tagger = NLTagger(tagSchemes: [.tokenType])
        tagger.string = text

        let range = text.startIndex..<text.endIndex
        tagger.enumerateTags(in: range, unit: .word, scheme: .tokenType, options: [.omitPunctuation, .omitWhitespace, .joinNames]) { _, tokenRange in
            words.append(String(text[tokenRange]))
            return true
        }

        return Set(words)
    }

    private func overlapScore(tokens: Set<String>, keywords: Set<String>) -> Double {
        guard !keywords.isEmpty else { return 0 }
        let hits = tokens.intersection(keywords).count
        return Double(hits) / Double(keywords.count)
    }
}
