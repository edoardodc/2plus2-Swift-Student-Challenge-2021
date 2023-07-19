import UIKit

class HeartsView: UIView {
    
    private var hearts: [UIImageView] = []
    private let heartImage = UIImage(named: "FullHearth")
    private let emptyHeartImage = UIImage(named: "EmptyHearth")
    
    public var numHearths = 3
    
    private let heartsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupHeartsView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: 55).isActive = true
        widthAnchor.constraint(greaterThanOrEqualToConstant: 180).isActive = true

        backgroundColor = .white
        layer.cornerRadius = 13
        layer.borderWidth = 4
        layer.borderColor = Colors.red.cgColor
    }
    
    private func setupHeartsView() {
        addSubview(heartsStackView)
        heartsStackView.translatesAutoresizingMaskIntoConstraints = false
        heartsStackView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        heartsStackView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        heartsStackView.widthAnchor.constraint(equalToConstant: 170).isActive = true

        for _ in 0..<3 {
            let heartImageView = UIImageView(image: heartImage)
            heartImageView.translatesAutoresizingMaskIntoConstraints = false
            heartImageView.heightAnchor.constraint(equalToConstant: 30).isActive = true
            heartImageView.contentMode = .scaleAspectFit
            heartsStackView.addArrangedSubview(heartImageView)
            hearts.append(heartImageView)
        }
    }
    
    func removeHeart() {
        guard hearts.count > 0 else { return }
        let lastHeart = hearts.removeLast()
        lastHeart.image = emptyHeartImage
        heartsStackView.addArrangedSubview(lastHeart)
    }

    func resetHearts() {
        for subview in heartsStackView.arrangedSubviews {
            heartsStackView.removeArrangedSubview(subview)
            subview.removeFromSuperview()
        }
        setupHeartsView()
    }
}

