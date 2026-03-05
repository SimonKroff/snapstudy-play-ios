import Foundation

struct EngineRegistry {
    let specs: [EngineSpec] = [
        EngineSpec(
            engine: .mathDash,
            title: "Math Dash",
            subjects: [.math],
            competencies: [.arithmeticFluency],
            templateSchema: EngineRegistry.standardSchema
        ),
        EngineSpec(
            engine: .equationBuilder,
            title: "Equation Builder",
            subjects: [.math],
            competencies: [.equationReasoning],
            templateSchema: EngineRegistry.standardSchema
        ),
        EngineSpec(
            engine: .fractionForge,
            title: "Fraction Forge",
            subjects: [.math],
            competencies: [.fractionSense],
            templateSchema: EngineRegistry.standardSchema
        ),
        EngineSpec(
            engine: .wordHunter,
            title: "Word Hunter",
            subjects: [.language],
            competencies: [.translation, .vocabularyDepth],
            templateSchema: EngineRegistry.standardSchema
        ),
        EngineSpec(
            engine: .synonymSprint,
            title: "Synonym Sprint",
            subjects: [.language],
            competencies: [.vocabularyDepth],
            templateSchema: EngineRegistry.standardSchema
        ),
        EngineSpec(
            engine: .grammarGate,
            title: "Grammar Gate",
            subjects: [.language],
            competencies: [.grammarControl, .readingComprehension],
            templateSchema: EngineRegistry.standardSchema
        ),
        EngineSpec(
            engine: .storyEscape,
            title: "Story Escape",
            subjects: [.language, .socialStudies],
            competencies: [.readingComprehension],
            templateSchema: EngineRegistry.standardSchema
        ),
        EngineSpec(
            engine: .timelineQuest,
            title: "Timeline Quest",
            subjects: [.socialStudies, .language],
            competencies: [.timelineReasoning, .readingComprehension],
            templateSchema: EngineRegistry.standardSchema
        ),
        EngineSpec(
            engine: .moleculeBuilder,
            title: "Molecule Builder",
            subjects: [.science],
            competencies: [.scientificModeling],
            templateSchema: EngineRegistry.standardSchema
        ),
        EngineSpec(
            engine: .ecosystemBalance,
            title: "Ecosystem Balance",
            subjects: [.science],
            competencies: [.ecosystemReasoning, .scientificModeling],
            templateSchema: EngineRegistry.standardSchema
        )
    ]

    func spec(for engine: GameEngineType) -> EngineSpec {
        specs.first(where: { $0.engine == engine }) ?? specs[0]
    }

    func selectEngine(for assignment: Assignment) -> GameEngineType {
        let competencyMatches = specs.filter { spec in
            !Set(spec.competencies).isDisjoint(with: assignment.learningProfile.competencies)
        }
        let subjectMatches = specs.filter { spec in
            spec.subjects.contains(assignment.learningProfile.subject)
        }

        let pool: [EngineSpec]
        if !competencyMatches.isEmpty {
            pool = competencyMatches
        } else if !subjectMatches.isEmpty {
            pool = subjectMatches
        } else {
            pool = specs
        }
        let seed = abs(assignment.rawText.hashValue)
        let index = seed % pool.count
        return pool[index].engine
    }

    func buildBlueprint(for assignment: Assignment, progress: LearnerProgress, engine: GameEngineType) -> GameBlueprint {
        let difficulty = ProgressionEngine().recommendedDifficulty(for: assignment, progress: progress)
        let seed = abs(assignment.rawText.hashValue ^ engine.rawValue.hashValue)
        let rounds = roundsForDifficulty(difficulty)
        let timeLimit = timeLimitForDifficulty(difficulty)

        return GameBlueprint(
            templateId: "tpl-\(engine.rawValue)",
            engine: engine,
            subject: assignment.learningProfile.subject,
            competencies: assignment.learningProfile.competencies,
            gradeBand: assignment.learningProfile.gradeBand,
            difficulty: difficulty,
            rounds: rounds,
            timeLimitSeconds: timeLimit,
            seed: seed,
            parameters: [
                "distractorCount": difficulty.rawValue >= 3 ? "3" : "2",
                "inputLength": assignment.rawText.count > 220 ? "long" : "short",
                "aiSource": assignment.aiSource
            ]
        )
    }

    private func roundsForDifficulty(_ difficulty: DifficultyTier) -> Int {
        switch difficulty {
        case .intro: return 3
        case .core: return 5
        case .advanced: return 7
        case .challenge: return 9
        }
    }

    private func timeLimitForDifficulty(_ difficulty: DifficultyTier) -> Int {
        switch difficulty {
        case .intro: return 90
        case .core: return 75
        case .advanced: return 60
        case .challenge: return 45
        }
    }

    private static let standardSchema: [TemplateFieldSchema] = [
        TemplateFieldSchema(key: "prompt", valueType: "string", required: true, description: "Task prompt shown to player"),
        TemplateFieldSchema(key: "correctOption", valueType: "string", required: true, description: "Correct answer token or text"),
        TemplateFieldSchema(key: "distractors", valueType: "string[]", required: true, description: "Wrong-but-plausible alternatives"),
        TemplateFieldSchema(key: "rounds", valueType: "int", required: true, description: "Number of rounds generated"),
        TemplateFieldSchema(key: "timeLimitSeconds", valueType: "int", required: false, description: "Suggested timer for session")
    ]
}
