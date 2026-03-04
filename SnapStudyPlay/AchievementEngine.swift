import Foundation

struct AchievementEngine {
    private let steamCardThreshold = 15

    func evaluate(score: Int) -> RewardPrototype {
        if score >= steamCardThreshold {
            return RewardPrototype(
                unlocked: true,
                title: "Steam Rabattkort (Fiktiv)",
                description: "Prototype reward unlocked. Ikke ekte kort, kun demo for fremtidig reward-system.",
                minimumScore: steamCardThreshold
            )
        }

        let remaining = max(steamCardThreshold - score, 0)
        return RewardPrototype(
            unlocked: false,
            title: "Steam Rabattkort (Fiktiv)",
            description: "Trenger \(remaining) poeng til for unlock i prototype.",
            minimumScore: steamCardThreshold
        )
    }
}
