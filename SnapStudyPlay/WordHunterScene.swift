import SpriteKit

final class WordHunterScene: SKScene {
    private let prompt: String
    private let sourceText: String
    private let onScoreChanged: (Int) -> Void

    private let scoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    private let feedbackLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
    private var score = 0
    private var targetWord = ""

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
        buildScene()
    }

    private func buildScene() {
        removeAllChildren()

        let promptLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        promptLabel.text = prompt
        promptLabel.fontSize = 22
        promptLabel.numberOfLines = 2
        promptLabel.preferredMaxLayoutWidth = size.width - 60
        promptLabel.position = CGPoint(x: size.width / 2, y: size.height - 50)
        addChild(promptLabel)

        scoreLabel.text = "Score: \(score)"
        scoreLabel.fontSize = 22
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.position = CGPoint(x: 40, y: size.height - 42)
        addChild(scoreLabel)

        feedbackLabel.text = "Trykk riktig ord"
        feedbackLabel.fontSize = 18
        feedbackLabel.fontColor = .lightGray
        feedbackLabel.position = CGPoint(x: size.width / 2, y: 56)
        addChild(feedbackLabel)

        let options = makeOptions(from: sourceText)
        targetWord = options.correct
        placeWordButtons(words: options.shuffled)
        onScoreChanged(score)
    }

    private func makeOptions(from text: String) -> (correct: String, shuffled: [String]) {
        let words = tokenizeWords(text)
        let correct = extractTargetWord(from: text, fallbackWords: words)

        let fallbackDecoys = [
            "book", "lesson", "school", "answer", "chapter",
            "science", "history", "language", "topic", "learn"
        ]

        var decoys = words.filter { $0 != correct }
        decoys.append(contentsOf: fallbackDecoys.filter { $0 != correct })
        let uniqueDecoys = orderedUnique(decoys).prefix(3)

        var options = [correct]
        options.append(contentsOf: uniqueDecoys)

        while options.count < 4 {
            options.append("word\(options.count)")
        }

        return (correct, options.shuffled())
    }

    private func tokenizeWords(_ text: String) -> [String] {
        text
            .split(whereSeparator: { !$0.isLetter && !$0.isNumber })
            .map { String($0).lowercased() }
            .filter { $0.count >= 3 }
    }

    private func extractTargetWord(from text: String, fallbackWords: [String]) -> String {
        let lowered = text.lowercased()
        let markers = ["translate", "oversett", "meaning of", "define", "betyr"]

        for marker in markers {
            guard let range = lowered.range(of: marker) else { continue }
            let slice = text[range.upperBound...]
            let parts = slice
                .split(whereSeparator: { $0.isWhitespace || $0.isPunctuation })
                .map { String($0).lowercased() }
                .filter { $0.count >= 2 }
            if let first = parts.first {
                return first
            }
        }

        return fallbackWords.first ?? "study"
    }

    private func orderedUnique(_ words: [String]) -> [String] {
        var seen: Set<String> = []
        var unique: [String] = []
        for word in words where !seen.contains(word) {
            seen.insert(word)
            unique.append(word)
        }
        return unique
    }

    private func placeWordButtons(words: [String]) {
        let width: CGFloat = 220
        let height: CGFloat = 52
        let startY = size.height * 0.62
        let spacingY: CGFloat = 70

        for (index, word) in words.enumerated() {
            let button = SKShapeNode(rectOf: CGSize(width: width, height: height), cornerRadius: 12)
            button.fillColor = .systemBlue
            button.strokeColor = .clear
            button.position = CGPoint(x: size.width / 2, y: startY - CGFloat(index) * spacingY)
            button.name = "word_\(word)"

            let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
            label.text = word.capitalized
            label.fontSize = 22
            label.verticalAlignmentMode = .center
            label.name = "word_\(word)"
            button.addChild(label)

            addChild(button)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNodes = nodes(at: location)

        for node in touchedNodes {
            guard let name = node.name ?? node.parent?.name,
                  name.starts(with: "word_") else { continue }

            let chosen = String(name.dropFirst("word_".count))
            if chosen == targetWord {
                score += 1
                scoreLabel.text = "Score: \(score)"
                feedbackLabel.text = "Riktig! Ny runde..."
                feedbackLabel.fontColor = .systemGreen
                onScoreChanged(score)
                run(.sequence([.wait(forDuration: 0.6), .run { [weak self] in self?.buildScene() }]))
            } else {
                feedbackLabel.text = "Feil. Riktig ord: \(targetWord.capitalized)"
                feedbackLabel.fontColor = .systemRed
            }
            break
        }
    }
}
