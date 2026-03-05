import Foundation

struct LearnerProgressStore {
    private let defaults: UserDefaults

    private let sessionsKey = "progress.sessionsCompleted"
    private let streakKey = "progress.streak"
    private let masteryKey = "progress.mastery"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func load() -> LearnerProgress {
        let sessions = defaults.integer(forKey: sessionsKey)
        let streak = defaults.integer(forKey: streakKey)
        let rawMastery = defaults.dictionary(forKey: masteryKey) as? [String: Int] ?? [:]

        var mastery: [CompetencyGoal: Int] = [:]
        for (raw, value) in rawMastery {
            guard let key = CompetencyGoal(rawValue: raw) else { continue }
            mastery[key] = max(0, min(100, value))
        }

        return LearnerProgress(
            sessionsCompleted: sessions,
            streak: streak,
            mastery: mastery
        )
    }

    func save(_ progress: LearnerProgress) {
        defaults.set(progress.sessionsCompleted, forKey: sessionsKey)
        defaults.set(progress.streak, forKey: streakKey)
        let rawMastery = Dictionary(uniqueKeysWithValues: progress.mastery.map { ($0.key.rawValue, $0.value) })
        defaults.set(rawMastery, forKey: masteryKey)
    }
}
