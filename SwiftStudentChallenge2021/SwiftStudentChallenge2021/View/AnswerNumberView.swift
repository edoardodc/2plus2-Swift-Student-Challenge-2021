import Foundation
import UIKit

class AnswerNumberView: UIView {
    
    var circleProgressionView: CircleProgressionView?
    var progress: CGFloat = 0
    
    let waitingLabel: AnswerNumberLabel = {
        let label = AnswerNumberLabel()
        label.text = "🖐"
        return label
    }()
    
    let numberLabel: AnswerNumberLabel = {
        let label = AnswerNumberLabel()
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: CGRect.zero)
        setupCircleProgressionView()
        setupView()
        setupNumberLabel()
        setupWaitingLabel()
    }
    
    private func setupCircleProgressionView() {
        circleProgressionView = CircleProgressionView(frame: CGRect(x: 0, y: 0, width: 110, height: 110))
        guard let circleProgressionView = circleProgressionView else { return }
        self.addSubview(circleProgressionView)
        circleProgressionView.translatesAutoresizingMaskIntoConstraints = false
        circleProgressionView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        circleProgressionView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        circleProgressionView.heightAnchor.constraint(equalToConstant: 110).isActive = true
        circleProgressionView.widthAnchor.constraint(equalToConstant: 110).isActive = true
        updateProgress(progress: 0)
        circleProgressionView.color = Colors.lightblue
    }
    
    public func updateProgress(progress: CGFloat) {
        guard let circleProgressionView = circleProgressionView else { return }
        circleProgressionView.progress = progress
    }
    
    public func updateLabel(answer: Int) {
        if answer == -1 {
            numberLabel.isHidden = true
            waitingLabel.isHidden = false
            return
        } else {
            numberLabel.isHidden = false
            waitingLabel.isHidden = true
            numberLabel.text = String(answer)
        }
        
    }
    
    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .white
        heightAnchor.constraint(equalToConstant: 110).isActive = true
        widthAnchor.constraint(equalToConstant: 110).isActive = true
        layer.masksToBounds = true
        layer.cornerRadius = 55
    }
    
    private func setupNumberLabel() {
        self.addSubview(numberLabel)
        numberLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        numberLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
    }
    
    private func setupWaitingLabel() {
        self.addSubview(waitingLabel)
        waitingLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        waitingLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        waitingLabel.count()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
