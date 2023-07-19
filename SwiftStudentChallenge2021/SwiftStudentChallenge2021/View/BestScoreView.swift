import Foundation
import UIKit

class BestScoreView: UIView {
    
    private let scoreLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.blue
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Arial Rounded MT Bold", size: 28)
        label.text = "Best Score: 0"
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = .white
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: 44).isActive = true
        widthAnchor.constraint(greaterThanOrEqualToConstant: 180).isActive = true

        layer.cornerRadius = 12
    
        layer.borderWidth = 3
        layer.borderColor = Colors.blue.cgColor
        
        self.addSubview(scoreLabel)
        scoreLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        scoreLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        scoreLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -10).isActive = true
        scoreLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 10).isActive = true
    }
    
    public func setBestScore(score: Int, bounce: Bool) {
        scoreLabel.text = "Best Score: \(score)"
        layer.borderColor = Colors.blue.cgColor
        scoreLabel.textColor = Colors.blue
        if !bounce { return }
        self.labelBounceAnimation(duration: [0.3/1.5, 0.3/2, 0.3/2], scale: [0.5, 1.3, 0.9])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

