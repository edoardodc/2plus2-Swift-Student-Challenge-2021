import Foundation
import UIKit

class HelpView: UIView {
    
    private let label: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Arial Rounded MT Bold", size: 25)
        label.text = "Draw the missing number!"
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    private func setupView() {
        self.backgroundColor = .white
        self.translatesAutoresizingMaskIntoConstraints = false
        self.heightAnchor.constraint(equalToConstant: 45).isActive = true
        self.widthAnchor.constraint(equalToConstant: 355).isActive = true
        self.layer.cornerRadius = 15
        self.layer.shadowOpacity = 0.15
        self.layer.shadowOffset = CGSize(width: 2, height: 2)
            
        self.addSubview(label)
        label.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
