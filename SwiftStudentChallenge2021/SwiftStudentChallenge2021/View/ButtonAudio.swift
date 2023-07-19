import Foundation
import UIKit

class ButtonAudio: UIButton {
    
    let height: CGFloat = 75
    let width: CGFloat = 75
    var color = UIColor.gray
    var hiddenView: UIView?
    var playAudio = true
    
    override open var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? self.color.darker(by: 10) : color
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: width, height: height))
        setupView()
    }

    func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: height).isActive = true
        widthAnchor.constraint(equalToConstant: width).isActive = true
        backgroundColor = color
        layer.cornerRadius = frame.height/2
        setupShadow()
        setImage(UIImage(named: "ButtonAudio.png"), for: .normal)
    }
    
    private func setupShadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = 4
        layer.shadowOpacity = 0.3
        layer.shadowOffset = CGSize(width: 0, height: 0)
    }
    
    public func setState() {
        self.playAudio = !playAudio
        
        print(playAudio)
        if playAudio {
            setImage(UIImage(named: "ButtonAudio.png"), for: .normal)
        } else {
            setImage(UIImage(named: "ButtonSilent.png"), for: .normal)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
