import Foundation
import UIKit

class PaperSheetView: UIView {
    
    private let backgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = #colorLiteral(red: 0.9397355639, green: 1, blue: 0.7022370709, alpha: 1)
        view.alpha = 0.4
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    private func setupView() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.heightAnchor.constraint(equalToConstant: 70).isActive = true
        self.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "backgroundMath"))
        
        self.addSubview(backgroundView)
        backgroundView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        backgroundView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        backgroundView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        backgroundView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
