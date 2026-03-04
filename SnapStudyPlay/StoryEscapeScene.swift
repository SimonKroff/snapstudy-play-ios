import SpriteKit

final class StoryEscapeScene: SKScene {
    private let prompt: String
    private let sourceText: String
    private let onScoreChanged: (Int) -> Void

    private let infoLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
    private let streakLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    private var targetSentence = ""
    private var streak = 0

    init(prompt: String, sourceText: String, onScoreChanged: @escaping (Int) -> Void = { _ in }) {
        self.prompt = prompt
        self.sourceText = sourceText
        self.onScoreChanged = onScoreChanged
        super.init(size: CGSize(width: 700, height: 360))
        scaleMode = .resizeFill
    }

    required init?(coder aDecoder: NSCoder) {
        nil
    }

    override func didMove(to view: SKView) {
        backgroundColor = .black
        buildRound()
    }

    private func buildRound() {
        removeAllChildren()

        let titleLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        titleLabel.text = prompt
        titleLabel.fontSize = 22
        titleLabel.numberOfLines = 2
        titleLabel.preferredMaxLayoutWidth = size.width - 60
        titleLabel.position = CGPoint(x: size.width / 2, y: size.height - 48)
        addChild(titleLabel)

        streakLabel.text = "Streak: \(streak)"
        streakLabel.fontSize = 21
        streakLabel.horizontalAlignmentMode = .left
        streakLabel.position = CGPoint(x: 40, y: size.height - 40)
        addChild(streakLabel)

        infoLabel.text = "Velg hendelsen som passer best"
        infoLabel.fontSize = 18
        infoLabel.fontColor = .lightGray
        infoLabel.position = CGPoint(x: size.width / 2, y: 50)
        addChild(infoLabel)

        let options = makeStoryOptions(from: sourceText)
        targetSentence = options.correct
        placeOptions(options.shuffled)
        onScoreChanged(streak)
    }

    private func makeStoryOptions(from text: String) -> (correct: String, shuffled: [String]) {
        let rawParts = text
            .components(separatedBy: CharacterSet(charactersIn: ".!?"))
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { $0.count >= 8 }

        let unique = orderedUnique(rawParts)
        let correct = pickBestSentence(from: unique) ?? "Hovedpersonen finner en nøkkel."
        var distractors = unique.filter { $0 != correct }

        let fallback = [
            "En sidefigur mister kartet.",
            "Lyset blinker i korridoren.",
            "The door is still locked."
        ]
        distractors.append(contentsOf: fallback.filter { $0 != correct })

        var options = [correct]
        options.append(contentsOf: distractors.prefix(2))

        while options.count < 3 {
            options.append("Ledetraden mangler fortsatt.")
        }

        return (correct, options.shuffled())
    }

    private func pickBestSentence(from sentences: [String]) -> String? {
        let keywords = [
            "then", "finally", "because", "therefore", "unlock", "opens",
            "så", "derfor", "til slutt", "åpner", "låser opp"
        ]

        if let matched = sentences.first(where: { sentence in
            let lowered = sentence.lowercased()
            return keywords.contains(where: lowered.contains)
        }) {
            return matched
        }

        return sentences.first
    }

    private func orderedUnique(_ sentences: [String]) -> [String] {
        var seen: Set<String> = []
        var unique: [String] = []
        for sentence in sentences where !seen.contains(sentence) {
            seen.insert(sentence)
            unique.append(sentence)
        }
        return unique
    }

    private func placeOptions(_ options: [String]) {
        let width = size.width - 80
        let height: CGFloat = 64
        let startY = size.height * 0.62
        let spacing: CGFloat = 84

        for (index, sentence) in options.enumerated() {
            let card = SKShapeNode(rectOf: CGSize(width: width, height: height), cornerRadius: 12)
            card.fillColor = .systemIndigo
            card.strokeColor = .clear
            card.position = CGPoint(x: size.width / 2, y: startY - CGFloat(index) * spacing)
            card.name = "story_\(index)"

            let label = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
            label.text = sentence
            label.fontSize = 17
            label.numberOfLines = 2
            label.preferredMaxLayoutWidth = width - 24
            label.verticalAlignmentMode = .center
            label.name = "story_\(index)"
            card.addChild(label)

            let metadata = NSMutableDictionary()
            metadata["value"] = sentence
            card.userData = metadata
            addChild(card)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNodes = nodes(at: location)

        for node in touchedNodes {
            let container = (node as? SKShapeNode) ?? (node.parent as? SKShapeNode)
            guard let card = container,
                  let chosen = card.userData?["value"] as? String else { continue }

            if chosen == targetSentence {
                streak += 1
                infoLabel.text = "Riktig! Ny scene..."
                infoLabel.fontColor = .systemGreen
                onScoreChanged(streak)
                run(.sequence([.wait(forDuration: 0.7), .run { [weak self] in self?.buildRound() }]))
            } else {
                streak = 0
                infoLabel.text = "Feil valg. Prøv igjen."
                infoLabel.fontColor = .systemRed
                streakLabel.text = "Streak: 0"
                onScoreChanged(streak)
            }
            streakLabel.text = "Streak: \(streak)"
            break
        }
    }
}
