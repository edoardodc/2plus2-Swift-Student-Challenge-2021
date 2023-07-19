import Foundation
import UIKit

protocol AnswerNumberViewDelegate {
    func updateAnswerViewProgressCircle(progress: CGFloat)
    func updateAnswerViewLabel(answer: Int)
    func updateAnimationAnswerViewLabel(isTheAnswerRight: Bool)
}

