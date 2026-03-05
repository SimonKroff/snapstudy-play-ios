import Foundation

struct ProgressionEngine {
    func recommendedDifficulty(for assignment: Assignment, progress: LearnerProgress) -> DifficultyTier {
        let competencyScores = assignment.learningProfile.competencies.map { progress.mastery[$0] ?? 0 }
        let averageMastery = competencyScores.isEmpty ? 0 : competencyScores.reduce(0, +) / competencyScores.count

        if progress.sessionsCompleted < 3 || averageMastery < 30 {
            return .intro
        }
        if averageMastery < 60 {
            return .core
        }
        if averageMastery < 85 {
            return .advanced
        }
        return .challenge
    }

    func startSession(current: LearnerProgress) -> LearnerProgress {
        var next = current
        next.sessionsCompleted += 1
        return next
    }

    func observeScore(current: LearnerProgress, score: Int, assignment: Assignment) -> LearnerProgress {
        var next = current
        next.streak = score > 0 ? current.streak + 1 : 0
        let delta = score >= 6 ? 8 : (score >= 3 ? 4 : 1)
        for competency in assignment.learningProfile.competencies {
            let currentValue = next.mastery[competency] ?? 0
            next.mastery[competency] = min(100, currentValue + delta)
        }
        return next
    }
}
