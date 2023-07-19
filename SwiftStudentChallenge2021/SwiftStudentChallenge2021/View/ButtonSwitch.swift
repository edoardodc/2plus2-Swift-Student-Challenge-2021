import Foundation
import UIKit

class ButtonSwitch: UIButton {
    
    let height: CGFloat = 75
    let width: CGFloat = 75
    var color = UIColor.gray
    var hiddenView: UIView?
    
    override open var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? self.color.darker(by: 10) : color
        }
    }
        
    let activityIndicatorView: UIActivityIndicatorView = {
        var activityIndicatorView = UIActivityIndicatorView(style: .medium)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        return activityIndicatorView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: width, height: height))
        setupView()
    }
    
    public func showARImage() {
        hiddenView?.removeFromSuperview()
        activityIndicatorView.removeFromSuperview()
        setImage(UIImage(named: "ButtonAR.png"), for: .normal)
    }
    
    public func hideARImage() {
        hiddenView = UIView()
        guard let hiddenView = hiddenView else { return }
        
        self.addSubview(hiddenView)
        self.addSubview(self.activityIndicatorView)
        self.activityIndicatorView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        self.activityIndicatorView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        self.activityIndicatorView.startAnimating()
        self.activityIndicatorView.color = .black
        
        hiddenView.translatesAutoresizingMaskIntoConstraints = false
        hiddenView.heightAnchor.constraint(equalToConstant: 45).isActive = true
        hiddenView.widthAnchor.constraint(equalToConstant: 45).isActive = true
        hiddenView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        hiddenView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        hiddenView.backgroundColor = .white
    }
    
    func updateButtonImageByStateInput(stateInput: StateInput) {
        switch stateInput {
        case .drawing:
            setImage(UIImage(named: "ButtonHand.png"), for: .normal)
        case .hands:
            setImage(UIImage(named: "ButtonDraw.png"), for: .normal)
        }
    }
    
    func setImageAsButtonAR() {
        setImage(UIImage(named: "ButtonAR.png"), for: .normal)
    }
    
    func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: height).isActive = true
        widthAnchor.constraint(equalToConstant: width).isActive = true
        backgroundColor = color
        layer.cornerRadius = frame.height/2
        setupShadow()
    }
    
    public func setupShadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = 4
        layer.shadowOpacity = 0.3
        layer.shadowOffset = CGSize(width: 0, height: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
