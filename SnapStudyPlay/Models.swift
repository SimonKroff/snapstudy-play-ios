import Foundation

enum AssignmentType: Equatable {
    case math
    case vocabulary
    case story
    case science
    case unknown
}

enum SubjectDomain: String, CaseIterable, Hashable {
    case math
    case language
    case science
    case socialStudies
    case mixed
}

enum CompetencyGoal: String, CaseIterable, Hashable {
    case arithmeticFluency
    case equationReasoning
    case fractionSense
    case vocabularyDepth
    case grammarControl
    case readingComprehension
    case scientificModeling
    case ecosystemReasoning
    case timelineReasoning
    case translation
}

enum GradeBand: String, CaseIterable {
    case grade1to3
    case grade4to6
    case grade7to9
    case grade10to12
}

enum DifficultyTier: Int, CaseIterable {
    case intro = 1
    case core = 2
    case advanced = 3
    case challenge = 4
}

struct LearningProfile {
    let subject: SubjectDomain
    let competencies: [CompetencyGoal]
    let gradeBand: GradeBand
    let difficulty: DifficultyTier
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
    let learningProfile: LearningProfile
}

enum GameEngineType: String, CaseIterable {
    case mathDash
    case wordHunter
    case storyEscape
    case moleculeBuilder
    case equationBuilder
    case fractionForge
    case synonymSprint
    case grammarGate
    case timelineQuest
    case ecosystemBalance
}

struct TemplateFieldSchema {
    let key: String
    let valueType: String
    let required: Bool
    let description: String
}

struct EngineSpec {
    let engine: GameEngineType
    let title: String
    let subjects: [SubjectDomain]
    let competencies: [CompetencyGoal]
    let templateSchema: [TemplateFieldSchema]
}

struct GameBlueprint {
    let templateId: String
    let engine: GameEngineType
    let subject: SubjectDomain
    let competencies: [CompetencyGoal]
    let gradeBand: GradeBand
    let difficulty: DifficultyTier
    let rounds: Int
    let timeLimitSeconds: Int
    let seed: Int
    let parameters: [String: String]
}

struct GamePayload {
    let question: String
    let options: [Int]
    let correctAnswer: Int
    let textOptions: [String]
    let correctText: String?
}

struct GeneratedGame {
    let engine: GameEngineType
    let title: String
    let payload: GamePayload
    let blueprint: GameBlueprint
}

struct LearnerProgress: Equatable {
    var sessionsCompleted: Int
    var streak: Int
    var mastery: [CompetencyGoal: Int]

    static let initial = LearnerProgress(
        sessionsCompleted: 0,
        streak: 0,
        mastery: [:]
    )
}

struct RewardPrototype {
    let unlocked: Bool
    let title: String
    let description: String
    let minimumScore: Int
}
