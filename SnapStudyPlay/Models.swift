import Foundation

enum AssignmentType: Equatable {
    case math
    case vocabulary
    case story
    case science
    case unknown
}

struct Assignment {
    let type: AssignmentType
    let rawText: String
    let extractedQuestion: String
    let options: [Int]
    let answer: Int
    let aiSource: String
    let classificationConfidence: Double
    let intelligenceSignals: [String]
}

enum GameEngineType: String {
    case mathDash
    case wordHunter
    case storyEscape
    case moleculeBuilder
}

struct GamePayload {
    let question: String
    let options: [Int]
    let correctAnswer: Int
}

struct GeneratedGame {
    let engine: GameEngineType
    let title: String
    let payload: GamePayload
}

struct RewardPrototype {
    let unlocked: Bool
    let title: String
    let description: String
    let minimumScore: Int
}
