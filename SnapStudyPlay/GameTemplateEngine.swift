import Foundation

struct GameTemplateEngine {
    func generate(from assignment: Assignment) -> GeneratedGame {
        switch assignment.type {
        case .math:
            return buildGame(
                engine: .mathDash,
                title: "Math Dash",
                assignment: assignment
            )
        case .vocabulary:
            return buildGame(
                engine: .wordHunter,
                title: "Word Hunter",
                assignment: assignment
            )
        case .story:
            return buildGame(
                engine: .storyEscape,
                title: "Story Escape",
                assignment: assignment
            )
        case .science:
            return buildGame(
                engine: .moleculeBuilder,
                title: "Molecule Builder",
                assignment: assignment
            )
        case .unknown:
            return buildGame(
                engine: .wordHunter,
                title: "Adaptive Trainer",
                assignment: assignment
            )
        }
    }

    private func buildGame(engine: GameEngineType, title: String, assignment: Assignment) -> GeneratedGame {
        GeneratedGame(
            engine: engine,
            title: title,
            payload: GamePayload(
                question: assignment.extractedQuestion,
                options: assignment.options,
                correctAnswer: assignment.answer
            )
        )
    }
}
