import Foundation
import UIKit

class DismissARButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 25, weight: .medium, scale: .default)
        let image = UIImage(systemName: "xmark", withConfiguration: largeConfig)?.mask(with: .black)
        setImage(image, for: .normal)
        layer.masksToBounds = true
        layer.cornerRadius = 20
        heightAnchor.constraint(equalToConstant: 50).isActive = true
        widthAnchor.constraint(equalToConstant: 50).isActive = true
        backgroundColor = Colors.gray
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
