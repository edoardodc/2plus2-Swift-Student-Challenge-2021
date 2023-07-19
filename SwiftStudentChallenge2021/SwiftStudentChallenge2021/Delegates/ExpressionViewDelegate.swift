import Foundation

protocol ExpressionViewDelegate {
    func enteredRightNumber()
    func enteredWrongNumber()
    func skipExpression(answer: Int)
}
