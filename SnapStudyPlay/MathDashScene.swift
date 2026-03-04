import SpriteKit

final class MathDashScene: SKScene {
    private let question: String
    private let options: [Int]
    private let correctAnswer: Int

    private let runner = SKSpriteNode(color: .systemBlue, size: CGSize(width: 34, height: 34))
    private let scoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    private var score = 0

    init(question: String, options: [Int], correctAnswer: Int) {
        self.question = question
        self.options = options
        self.correctAnswer = correctAnswer
        super.init(size: CGSize(width: 700, height: 360))
        scaleMode = .resizeFill
    }

    required init?(coder aDecoder: NSCoder) {
        nil
    }

    override func didMove(to view: SKView) {
        backgroundColor = .black
        physicsWorld.gravity = .zero

        let questionLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        questionLabel.text = question
        questionLabel.fontSize = 30
        questionLabel.position = CGPoint(x: size.width / 2, y: size.height - 50)
        addChild(questionLabel)

        scoreLabel.text = "Streak: 0"
        scoreLabel.fontSize = 24
        scoreLabel.position = CGPoint(x: 90, y: size.height - 45)
        scoreLabel.horizontalAlignmentMode = .left
        addChild(scoreLabel)

        runner.position = CGPoint(x: 80, y: 90)
        runner.name = "runner"
        addChild(runner)

        let ground = SKSpriteNode(color: .darkGray, size: CGSize(width: size.width, height: 8))
        ground.position = CGPoint(x: size.width / 2, y: 70)
        addChild(ground)

        spawnAnswerGates()
    }

    private func spawnAnswerGates() {
        let startX = size.width * 0.45
        let spacing: CGFloat = 140

        for (index, value) in options.enumerated() {
            let gate = SKShapeNode(rectOf: CGSize(width: 100, height: 120), cornerRadius: 10)
            gate.fillColor = value == correctAnswer ? .systemGreen : .systemRed
            gate.strokeColor = .clear
            gate.position = CGPoint(x: startX + CGFloat(index) * spacing, y: 130)
            gate.name = "gate_\(value)"

            let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
            label.text = "\(value)"
            label.fontSize = 28
            label.verticalAlignmentMode = .center
            gate.addChild(label)

            addChild(gate)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touched = nodes(at: location)

        for node in touched {
            guard let name = node.name ?? node.parent?.name,
                  name.starts(with: "gate_"),
                  let chosen = Int(name.replacingOccurrences(of: "gate_", with: "")) else {
                continue
            }

            if chosen == correctAnswer {
                score += 1
                scoreLabel.text = "Streak: \(score)"
            } else {
                score = 0
                scoreLabel.text = "Streak: 0"
            }
        }
    }
}
