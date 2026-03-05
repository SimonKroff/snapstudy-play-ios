import SpriteKit

final class TemplateArenaScene: SKScene {
    private let prompt: String
    private let options: [String]
    private let correct: String
    private let onScoreChanged: (Int) -> Void

    private let scoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    private let statusLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
    private var score = 0

    init(prompt: String, options: [String], correct: String, onScoreChanged: @escaping (Int) -> Void = { _ in }) {
        self.prompt = prompt
        self.options = options
        self.correct = correct
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

        let title = SKLabelNode(fontNamed: "AvenirNext-Bold")
        title.text = prompt
        title.fontSize = 21
        title.numberOfLines = 2
        title.preferredMaxLayoutWidth = size.width - 60
        title.position = CGPoint(x: size.width / 2, y: size.height - 48)
        addChild(title)

        scoreLabel.text = "Score: \(score)"
        scoreLabel.fontSize = 21
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.position = CGPoint(x: 40, y: size.height - 40)
        addChild(scoreLabel)

        statusLabel.text = "Velg riktig svar"
        statusLabel.fontSize = 18
        statusLabel.fontColor = .lightGray
        statusLabel.position = CGPoint(x: size.width / 2, y: 48)
        addChild(statusLabel)

        let width = size.width - 90
        let startY = size.height * 0.65
        let spacing: CGFloat = 72
        let shuffled = options.shuffled()
        for (index, option) in shuffled.enumerated() {
            let node = SKShapeNode(rectOf: CGSize(width: width, height: 56), cornerRadius: 10)
            node.fillColor = .systemPurple
            node.strokeColor = .clear
            node.position = CGPoint(x: size.width / 2, y: startY - CGFloat(index) * spacing)
            node.name = "option_\(index)"
            node.userData = NSMutableDictionary(object: option, forKey: "value" as NSString)

            let label = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
            label.text = option
            label.fontSize = 17
            label.numberOfLines = 2
            label.preferredMaxLayoutWidth = width - 20
            label.verticalAlignmentMode = .center
            label.name = node.name
            node.addChild(label)
            addChild(node)
        }
        onScoreChanged(score)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touched = nodes(at: location)

        for node in touched {
            let container = (node as? SKShapeNode) ?? (node.parent as? SKShapeNode)
            guard let optionNode = container,
                  let choice = optionNode.userData?["value"] as? String else { continue }

            if choice == correct {
                score += 1
                statusLabel.text = "Riktig!"
                statusLabel.fontColor = .systemGreen
            } else {
                score = max(0, score - 1)
                statusLabel.text = "Feil. Riktig svar: \(correct)"
                statusLabel.fontColor = .systemRed
            }
            scoreLabel.text = "Score: \(score)"
            onScoreChanged(score)
            run(.sequence([.wait(forDuration: 0.7), .run { [weak self] in self?.buildRound() }]))
            break
        }
    }
}
