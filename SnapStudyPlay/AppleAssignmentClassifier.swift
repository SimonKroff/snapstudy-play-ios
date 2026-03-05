import Foundation
import NaturalLanguage

struct AssignmentClassification {
    let type: AssignmentType
    let confidence: Double
    let source: String
    let signals: [String]
}

struct AppleAssignmentClassifier {
    private struct TypeProfile {
        let keywords: Set<String>
        let anchors: [String]
    }

    private let profiles: [AssignmentType: TypeProfile] = [
        .vocabulary: TypeProfile(
            keywords: ["translate", "oversett", "gloser", "vocabulary", "meaning", "ordliste", "synonym", "define", "antonym"],
            anchors: [
                "translate this word",
                "find the meaning of the word",
                "oversett ordet",
                "hva betyr dette ordet"
            ]
        ),
        .story: TypeProfile(
            keywords: ["story", "chapter", "character", "historie", "tekst", "handling", "forfatter", "plot", "narrative"],
            anchors: [
                "what happened in the chapter",
                "which event fits the story",
                "hvilken hendelse passer teksten",
                "hva gjør hovedpersonen"
            ]
        ),
        .science: TypeProfile(
            keywords: ["molecule", "atom", "periodic", "naturfag", "kjemi", "fysikk", "biologi", "formula", "compound"],
            anchors: [
                "identify the molecule formula",
                "science question about atoms",
                "hvilken molekylformel er riktig",
                "kjemi oppgave om stoff"
            ]
        )
    ]

    func classify(text: String) -> AssignmentClassification {
        let lowered = text.lowercased()
        let tokens = tokenize(lowered)
        let lemmas = lemmatize(lowered)
        let detectedLanguage = detectLanguage(text)
        let langConfidence = languageConfidence(text)
        let entitySignals = extractEntitySignals(from: text)

        let vocabularyScore = score(.vocabulary, text: lowered, tokens: tokens, lemmas: lemmas, language: detectedLanguage, langConfidence: langConfidence, entitySignals: entitySignals)
        let storyScore = score(.story, text: lowered, tokens: tokens, lemmas: lemmas, language: detectedLanguage, langConfidence: langConfidence, entitySignals: entitySignals)
        let scienceScore = score(.science, text: lowered, tokens: tokens, lemmas: lemmas, language: detectedLanguage, langConfidence: langConfidence, entitySignals: entitySignals)

        let sorted: [(AssignmentType, Double)] = [
            (.vocabulary, vocabularyScore),
            (.story, storyScore),
            (.science, scienceScore)
        ]
        .sorted { $0.1 > $1.1 }

        guard let winner = sorted.first else {
            return AssignmentClassification(
                type: .unknown,
                confidence: 0.0,
                source: "Apple NL hybrid classifier",
                signals: []
            )
        }

        let margin = winner.1 - (sorted.dropFirst().first?.1 ?? 0)
        let confidence = clamp((winner.1 * 0.8) + (margin * 0.2), min: 0, max: 1)

        if confidence < 0.28 {
            return AssignmentClassification(
                type: .unknown,
                confidence: confidence,
                source: "Apple NL hybrid classifier (low confidence)",
                signals: buildSignals(type: .unknown, language: detectedLanguage, entities: entitySignals, confidence: confidence)
            )
        }

        return AssignmentClassification(
            type: winner.0,
            confidence: confidence,
            source: "Apple NL hybrid classifier (keywords + lemmas + embeddings + entities)",
            signals: buildSignals(type: winner.0, language: detectedLanguage, entities: entitySignals, confidence: confidence)
        )
    }

    private func score(
        _ type: AssignmentType,
        text: String,
        tokens: Set<String>,
        lemmas: Set<String>,
        language: NLLanguage?,
        langConfidence: Double,
        entitySignals: EntitySignals
    ) -> Double {
        guard let profile = profiles[type] else { return 0 }

        let keywordScore = overlapScore(tokens: tokens.union(lemmas), keywords: profile.keywords)
        let semanticScore = semanticSimilarity(text: text, anchors: profile.anchors, language: language)
        let entityBoost = entityWeight(for: type, entities: entitySignals)

        let weighted = (keywordScore * 0.45) + (semanticScore * 0.35) + (langConfidence * 0.1) + (entityBoost * 0.1)
        return clamp(weighted, min: 0, max: 1)
    }

    private struct EntitySignals {
        var personCount = 0
        var organizationCount = 0
        var placeCount = 0
    }

    private func detectLanguage(_ text: String) -> NLLanguage? {
        let recognizer = NLLanguageRecognizer()
        recognizer.processString(text)
        return recognizer.dominantLanguage
    }

    private func languageConfidence(_ text: String) -> Double {
        let recognizer = NLLanguageRecognizer()
        recognizer.processString(text)
        return recognizer.languageHypotheses(withMaximum: 1).values.first ?? 0.5
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

    private func lemmatize(_ text: String) -> Set<String> {
        var lemmas: [String] = []
        let tagger = NLTagger(tagSchemes: [.lemma])
        tagger.string = text

        let range = text.startIndex..<text.endIndex
        tagger.enumerateTags(in: range, unit: .word, scheme: .lemma, options: [.omitPunctuation, .omitWhitespace]) { tag, tokenRange in
            if let lemma = tag?.rawValue, !lemma.isEmpty {
                lemmas.append(lemma.lowercased())
            } else {
                lemmas.append(String(text[tokenRange]).lowercased())
            }
            return true
        }

        return Set(lemmas)
    }

    private func extractEntitySignals(from text: String) -> EntitySignals {
        var signals = EntitySignals()
        let tagger = NLTagger(tagSchemes: [.nameType])
        tagger.string = text
        let range = text.startIndex..<text.endIndex

        tagger.enumerateTags(in: range, unit: .word, scheme: .nameType, options: [.joinNames, .omitWhitespace, .omitPunctuation]) { tag, _ in
            guard let tag else { return true }
            switch tag {
            case .personalName:
                signals.personCount += 1
            case .organizationName:
                signals.organizationCount += 1
            case .placeName:
                signals.placeCount += 1
            default:
                break
            }
            return true
        }
        return signals
    }

    private func semanticSimilarity(text: String, anchors: [String], language: NLLanguage?) -> Double {
        guard let language,
              let embedding = NLEmbedding.sentenceEmbedding(for: language),
              !anchors.isEmpty else {
            return 0
        }

        var best = 0.0
        for anchor in anchors {
            let distance = embedding.distance(between: text, and: anchor)
            if distance.isFinite {
                let similarity = clamp(1.0 - distance, min: 0, max: 1)
                best = max(best, similarity)
            }
        }
        return best
    }

    private func entityWeight(for type: AssignmentType, entities: EntitySignals) -> Double {
        switch type {
        case .story:
            return clamp(Double(entities.personCount + entities.placeCount) * 0.2, min: 0, max: 1)
        case .science:
            return clamp(Double(entities.organizationCount) * 0.15, min: 0, max: 1)
        case .vocabulary:
            return entities.personCount == 0 ? 0.25 : 0.1
        case .math, .unknown:
            return 0
        }
    }

    private func overlapScore(tokens: Set<String>, keywords: Set<String>) -> Double {
        guard !keywords.isEmpty else { return 0 }
        let hits = tokens.intersection(keywords).count
        return Double(hits) / Double(keywords.count)
    }

    private func clamp(_ value: Double, min: Double, max: Double) -> Double {
        Swift.max(min, Swift.min(max, value))
    }

    private func buildSignals(type: AssignmentType, language: NLLanguage?, entities: EntitySignals, confidence: Double) -> [String] {
        var values: [String] = []
        values.append("type=\(type)")
        if let language {
            values.append("lang=\(language.rawValue)")
        }
        values.append("confidence=\(Int(confidence * 100))%")
        values.append("entities:p\(entities.personCount)/o\(entities.organizationCount)/l\(entities.placeCount)")
        return values
    }
}
