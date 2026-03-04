import SpriteKit

final class MoleculeBuilderScene: SKScene {
    private let prompt: String
    private let sourceText: String
    private let onScoreChanged: (Int) -> Void

    private let statusLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
    private let scoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    private var score = 0
    private var targetFormula = ""

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

        scoreLabel.text = "Score: \(score)"
        scoreLabel.fontSize = 21
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.position = CGPoint(x: 40, y: size.height - 40)
        addChild(scoreLabel)

        statusLabel.text = "Velg korrekt formel"
        statusLabel.fontSize = 18
        statusLabel.fontColor = .lightGray
        statusLabel.position = CGPoint(x: size.width / 2, y: 50)
        addChild(statusLabel)

        let options = makeFormulaOptions(from: sourceText)
        targetFormula = options.correct
        placeFormulaOptions(options.shuffled)
        onScoreChanged(score)
    }

    private func makeFormulaOptions(from text: String) -> (correct: String, shuffled: [String]) {
        let lowered = text.lowercased()
        let catalog: [(keywords: [String], formula: String)] = [
            (["water", "vann"], "H2O"),
            (["co2", "karbondioksid", "carbon dioxide"], "CO2"),
            (["oxygen", "oksygen"], "O2"),
            (["ozone", "ozon"], "O3"),
            (["ammonia", "ammoniakk"], "NH3"),
            (["methane", "metan"], "CH4")
        ]

        let pool = ["H2O", "CO2", "O2", "O3", "NH3", "CH4"]
        for item in catalog {
            if item.keywords.contains(where: lowered.contains) {
                let distractors = pool.filter { $0 != item.formula }.shuffled().prefix(2)
                return (item.formula, ([item.formula] + distractors).shuffled())
            }
        }

        return ("CO2", ["CO2", "H2O", "O2"].shuffled())
    }

    private func placeFormulaOptions(_ options: [String]) {
        let startX = size.width * 0.28
        let spacingX = size.width * 0.24

        for (index, option) in options.enumerated() {
            let node = SKShapeNode(rectOf: CGSize(width: 130, height: 72), cornerRadius: 14)
            node.fillColor = .systemTeal
            node.strokeColor = .clear
            node.position = CGPoint(x: startX + CGFloat(index) * spacingX, y: size.height * 0.45)
            node.name = "formula_\(option)"

            let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
            label.text = option
            label.fontSize = 28
            label.verticalAlignmentMode = .center
            label.name = "formula_\(option)"
            node.addChild(label)

            addChild(node)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNodes = nodes(at: location)

        for node in touchedNodes {
            guard let name = node.name ?? node.parent?.name,
                  name.starts(with: "formula_") else { continue }

            let choice = String(name.dropFirst("formula_".count))
            if choice == targetFormula {
                score += 1
                statusLabel.text = "Riktig! Ny runde..."
                statusLabel.fontColor = .systemGreen
                run(.sequence([.wait(forDuration: 0.7), .run { [weak self] in self?.buildRound() }]))
            } else {
                score = max(0, score - 1)
                statusLabel.text = "Feil. Riktig: \(targetFormula)"
                statusLabel.fontColor = .systemRed
            }
            scoreLabel.text = "Score: \(score)"
            onScoreChanged(score)
            break
        }
    }
}
