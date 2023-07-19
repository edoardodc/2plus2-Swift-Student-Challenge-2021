import Foundation
import QuartzCore
import UIKit

public class ConfettiView: UIView {

    public enum ConfettiType {
        case confetti
        case star
        case diamond
    }

    var emitter: CAEmitterLayer?
    public var colors: [UIColor]?
    public var intensity: Float?
    public var type: ConfettiType?
    private var active: Bool?

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    func setup() {
        isUserInteractionEnabled = false
        colors = [UIColor(red:0.95, green:0.40, blue:0.27, alpha:1.0),
            UIColor(red:1.00, green:0.78, blue:0.36, alpha:1.0),
            UIColor(red:0.48, green:0.78, blue:0.64, alpha:1.0),
            UIColor(red:0.30, green:0.76, blue:0.85, alpha:1.0),
            UIColor(red:0.58, green:0.39, blue:0.55, alpha:1.0)]
        intensity = 0.6
        let types: [ConfettiType] = [.confetti, .star, .diamond]
        type = types[Int.random(in: 0...2)]
        active = false
    }
    
    func getConfettiType(type: ConfettiType) -> UIImage {
        switch type {
        case .confetti:
            return UIImage(named: "confetti.png") ?? UIImage()
        case .star:
            return UIImage(named: "star.png") ?? UIImage()
        case .diamond:
            return UIImage(named: "diamond.png") ?? UIImage()
        }
    }

    public func startConfetti(duration: TimeInterval = 0) {
        emitter = CAEmitterLayer()
        guard let emitter = emitter else { return }
        emitter.emitterPosition = CGPoint(x: frame.size.width / 2.0, y: 0)
        emitter.emitterShape = CAEmitterLayerEmitterShape.line
        emitter.emitterSize = CGSize(width: frame.size.width, height: 1)

        var cells = [CAEmitterCell]()
        
        guard let colors = self.colors else { return }
        for color in colors {
            cells.append(confettiWithColor(color: color))
        }

        emitter.emitterCells = cells
        layer.addSublayer(emitter)
        active = true
        
        if duration != 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + duration, execute: {
                self.stopConfetti()
            })
        }
    }

    public func stopConfetti() {
        emitter?.birthRate = 0
        active = false
    }

    func confettiWithColor(color: UIColor) -> CAEmitterCell {
        let confetti = CAEmitterCell()
        guard let intensity = self.intensity, let type = self.type else { return confetti }

        confetti.birthRate = 6.0 * intensity
        confetti.lifetime = 14.0 * intensity
        confetti.lifetimeRange = 0
        confetti.color = color.cgColor
        confetti.velocity = CGFloat(350.0 * intensity)
        confetti.velocityRange = CGFloat(80.0 * intensity)
        confetti.emissionLongitude = CGFloat(Double.pi)
        confetti.emissionRange = CGFloat(Double.pi / 10)
        confetti.spinRange = CGFloat(4.0 * intensity)
        confetti.scaleRange = CGFloat(intensity)
        confetti.scaleSpeed = CGFloat(-0.1 * intensity)
        confetti.contents = getConfettiType(type: type).cgImage
        return confetti
    }

    public func isActive() -> Bool {
        return self.active ?? false
    }
}
