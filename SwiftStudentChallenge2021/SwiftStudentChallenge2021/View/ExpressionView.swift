import Foundation
import UIKit

class ExpressionView: UIView {
    
//    public var score: Int = 0
    private var isEnteredNumber = false
    private var enteredNumbers = [String]()
    var expression: ExpressionManager?
    var delegate: ExpressionViewDelegate?
    var answerViewDelegate: AnswerNumberViewDelegate?
    private var wrongTimes = 0

    private let label: UILabel = {
        let label = UILabel()
        label.textColor = #colorLiteral(red: 0.07417424768, green: 0.5795522332, blue: 0.9657167792, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: Fonts.BrandonMed, size: 132)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        label.textAlignment = .center
        return label
    }()
    
//    private let scoreLabel: UILabel = {
//        let label = UILabel()
//        label.textColor = #colorLiteral(red: 0.07417424768, green: 0.5795522332, blue: 0.9657167792, alpha: 1)
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.font = UIFont(name: Fonts.BrandonMed, size: 38)
//        label.text = "Score: 0"
//        label.textAlignment = .center
//        return label
//    }()
    
    private var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.distribution = .fillProportionally
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setNewExpression()
        setupView()
    }
    
    private func setupView() {
        setupStackView()
        addShadow()
        
        backgroundColor = .white
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func addShadow() {
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowOpacity = 0.3
        layer.shadowOffset = CGSize(width: 0, height: 0)
    }
    
    private func setNewExpression() {
        expression = ExpressionManager()
        label.text = expression?.showExpressionText()
        setAttributedStringLabelExpression()
        enteredNumbers = [String]()
    }
    
    public func updateExpressionAndScore() {
        label.text = expression?.showExpressionText()
//        scoreLabel.text = "Score: \(score)"
        setAttributedStringLabelExpression()
    }
    
    private func updateScoreLabel() {
//        scoreLabel.text = "Score: \(score)"
//        scoreLabel.labelBounceAnimation(duration: [0.3/1.5, 0.3/2, 0.3/2], scale: [0.001, 1.1, 0.9])
    }
    
    private func setAttributedStringLabelExpression() {
        guard let expression = self.expression, let labelText = label.text else { return  }
        let attributedString = NSMutableAttributedString(string: labelText)
        attributedString.setColorForText(textForAttribute: expression.sign, withColor: expression.getColorOperation())
        attributedString.setColorForText(textForAttribute: "=", withColor: expression.getColorOperation())
        label.attributedText = attributedString
    }
    
    private func setupStackView() {
//        stackView.addArrangedSubview(scoreLabel)
        stackView.addArrangedSubview(label)
        addSubview(stackView)
        stackView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -2).isActive = true
        stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 2).isActive = true
//        stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
    }
    
    public func expressionEnterNumber(number: String) {
        if isEnteredNumber == true {
            enteredNumbers.append(number)
            return
        }
        
        isEnteredNumber = true
        label.text = expression?.enterNumber(number: number)
        
        let resultOfEnteredNumber = expression?.checkEnteredNumber(number: number)
        setAttributedStringLabelExpression()
        
        if resultOfEnteredNumber == .right {
//            updateScoreLabel()
            label.labelBounceAnimation(duration: [0.3/1.5, 0.3/2, 0.3/2], scale: [0.5, 1.3, 0.9])
            answerViewDelegate?.updateAnimationAnswerViewLabel(isTheAnswerRight: true)
            delegate?.enteredRightNumber()
            wrongTimes = 0
            let secondsToDelay = 1.5
            DispatchQueue.main.asyncAfter(deadline: .now() + secondsToDelay) {
                self.setNewExpression()
                self.isEnteredNumber = false
            }
        } else if resultOfEnteredNumber == .wrong {
            wrongTimes += 1
            delegate?.enteredWrongNumber()

            if wrongTimes == 3 {
                wrongTimes = 0
                delegate?.skipExpression(answer: expression?.numToFind ?? 0)
                label.text = expression?.completedExpressionString
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.3, execute: {
                    self.setNewExpression()
                    self.isEnteredNumber = false
                })
                return
            }
            
            let secondsToDelay = 0.7
            answerViewDelegate?.updateAnimationAnswerViewLabel(isTheAnswerRight: false)
            label.shake(duration: 0.7, rangeValues: [20, 10, 5])
             DispatchQueue.main.asyncAfter(deadline: .now() + secondsToDelay) {
                self.label.text = self.expression?.showExpressionText()
                self.setAttributedStringLabelExpression()
                self.isEnteredNumber = false
                self.checkIfEnteredAnotherNumber()
             }
        } else if resultOfEnteredNumber == .toContinue {
            self.isEnteredNumber = false
            answerViewDelegate?.updateAnimationAnswerViewLabel(isTheAnswerRight: true)
            wrongTimes = 0
        }
        
    }
    
    public func updateFontSize(size: CGFloat) {
        label.font = UIFont(name: Fonts.BrandonMed, size: size)
    }
    
    private func checkIfEnteredAnotherNumber() {
        if enteredNumbers.count >= 1 {
            expressionEnterNumber(number: enteredNumbers.last ?? "0")
            enteredNumbers.removeAll()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
