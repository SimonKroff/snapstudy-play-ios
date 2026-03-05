import Foundation

struct GameTemplateEngine {
    private let registry = EngineRegistry()

    func generate(from assignment: Assignment, progress: LearnerProgress = .initial) -> GeneratedGame {
        let selectedEngine = registry.selectEngine(for: assignment)
        let spec = registry.spec(for: selectedEngine)
        let blueprint = registry.buildBlueprint(for: assignment, progress: progress, engine: selectedEngine)
        let payload = buildPayload(for: assignment, engine: selectedEngine, blueprint: blueprint)

        return GeneratedGame(
            engine: selectedEngine,
            title: spec.title,
            payload: payload,
            blueprint: blueprint
        )
    }

    func engineCount() -> Int {
        registry.specs.count
    }

    private func buildPayload(for assignment: Assignment, engine: GameEngineType, blueprint: GameBlueprint) -> GamePayload {
        switch engine {
        case .mathDash:
            return GamePayload(
                question: assignment.extractedQuestion,
                options: assignment.options,
                correctAnswer: assignment.answer,
                textOptions: [],
                correctText: nil
            )
        case .equationBuilder:
            let equation = assignment.extractedQuestion.isEmpty ? "x + 5 = 9" : assignment.extractedQuestion
            let correctEquation = "x = \(assignment.answer)"
            let textOptions = [
                correctEquation,
                "x = \(max(0, assignment.answer + 1))",
                "x = \(max(0, assignment.answer + 2))",
                "x = \(max(0, assignment.answer > 0 ? assignment.answer - 1 : assignment.answer + 3))"
            ].shuffled()
            return GamePayload(
                question: "Løs ligningen: \(equation)",
                options: assignment.options,
                correctAnswer: assignment.answer,
                textOptions: textOptions,
                correctText: correctEquation
            )
        case .fractionForge:
            let textOptions = ["1/2", "2/3", "3/4", "4/5"].shuffled()
            return GamePayload(
                question: "Velg brøken som er størst",
                options: assignment.options,
                correctAnswer: assignment.answer,
                textOptions: textOptions,
                correctText: "4/5"
            )
        case .wordHunter:
            return GamePayload(
                question: assignment.extractedQuestion,
                options: assignment.options,
                correctAnswer: assignment.answer,
                textOptions: [],
                correctText: nil
            )
        case .synonymSprint:
            let word = extractWord(in: assignment.extractedQuestion) ?? "curious"
            let choices = ["inquisitive", "silent", "rigid", "slow"].shuffled()
            return GamePayload(
                question: "Finn synonym for: \(word)",
                options: assignment.options,
                correctAnswer: assignment.answer,
                textOptions: choices,
                correctText: "inquisitive"
            )
        case .grammarGate:
            let choices = [
                "She is going to school.",
                "She are going to school.",
                "She going to school.",
                "She were going to school."
            ].shuffled()
            return GamePayload(
                question: "Velg grammatisk korrekt setning",
                options: assignment.options,
                correctAnswer: assignment.answer,
                textOptions: choices,
                correctText: "She is going to school."
            )
        case .storyEscape:
            return GamePayload(
                question: assignment.extractedQuestion,
                options: assignment.options,
                correctAnswer: assignment.answer,
                textOptions: [],
                correctText: nil
            )
        case .timelineQuest:
            let choices = ["Start", "Konflikt", "Løsning", "Epilog"].shuffled()
            return GamePayload(
                question: "Plasser hendelsen i riktig rekkefølge",
                options: assignment.options,
                correctAnswer: assignment.answer,
                textOptions: choices,
                correctText: "Løsning"
            )
        case .moleculeBuilder:
            return GamePayload(
                question: assignment.extractedQuestion,
                options: assignment.options,
                correctAnswer: assignment.answer,
                textOptions: [],
                correctText: nil
            )
        case .ecosystemBalance:
            let choices = ["Produsent", "Konsument", "Nedbryter", "Abiotisk faktor"].shuffled()
            return GamePayload(
                question: "Velg rollen som passer organismen i næringskjeden",
                options: assignment.options,
                correctAnswer: assignment.answer,
                textOptions: choices,
                correctText: "Konsument"
            )
        }
    }

    private func extractWord(in question: String) -> String? {
        let parts = question.split(whereSeparator: { !$0.isLetter && !$0.isNumber })
        return parts.last.map(String.init)
    }
}
