import Foundation
import UIKit

class AnswerNumberLabel: UILabel {
    
    var timer: Timer?
    var counter = 0
    var handEmoticons = ["👍", "🖐", "👆", "🤙", "✌️", "🙌", "✊"]
    
    init() {
        super.init(frame: CGRect.zero)
        translatesAutoresizingMaskIntoConstraints = false
        font = UIFont(name: Fonts.BrandonMed, size: 52)
        textColor = .black
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func count() {
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(updateValue), userInfo: nil, repeats: true)
    }
    
    @objc func updateValue() {
        if counter == handEmoticons.count - 1 {
            counter = 0
        }
        counter += 1
        text = handEmoticons[counter]
    }
    
    public func invalidateTimer() {
        timer?.invalidate()
        timer = nil
    }
}
