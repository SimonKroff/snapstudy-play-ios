import Foundation

struct GameTemplateEngine {
    func generate(from assignment: Assignment) -> GeneratedGame {
        switch assignment.type {
        case .math:
            return GeneratedGame(
                engine: .mathDash,
                title: "Math Dash",
                payload: GamePayload(
                    question: assignment.extractedQuestion,
                    options: assignment.options,
                    correctAnswer: assignment.answer
                )
            )
        case .vocabulary:
            return fallback(engine: .wordHunter, title: "Word Hunter")
        case .story:
            return fallback(engine: .storyEscape, title: "Story Escape")
        case .science:
            return fallback(engine: .moleculeBuilder, title: "Molecule Builder")
        case .unknown:
            return fallback(engine: .wordHunter, title: "Adaptive Trainer")
        }
    }

    private func fallback(engine: GameEngineType, title: String) -> GeneratedGame {
        GeneratedGame(
            engine: engine,
            title: title,
            payload: GamePayload(question: "Prototype", options: [1, 2, 3], correctAnswer: 1)
        )
    }
}
