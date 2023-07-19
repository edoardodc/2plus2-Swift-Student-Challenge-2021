import Foundation
import UIKit

enum Sign {
    case multiplication
    case addition
    case division
    case subtraction
}

class ExpressionManager {
    
    private var firstNum: Int = 0
    private var secondNum: Int = 0
    private var resultNum: Int = 0
    private var underScorePosition: Int = 0
    private var stringArrayNumbers = [String]()
    private var numberOfDigits: Int = 0
    private var answerNumber: String = ""
    
    public var completedExpressionString: String?
    public var numToFind: Int = 0
    public var expressionString: String?
    public var sign = ""
    public var numToFindDigits = [Int]()
    
    var operationsAvailable = OperationsEnabled()
    var binaryOperation: BinaryOperation?
    
    private let signs: [Sign: (Int,Int) -> Int] = [
        .addition:       (+),
        .subtraction:    (-),
        .multiplication: (*),
        .division:       (/),
    ]
    
    init() {
        createExpression()
    }
    
    private func createExpression() {
        setNumbers()
        
        let arrayNumbers = [firstNum, secondNum, resultNum]
        stringArrayNumbers = arrayNumbers.map { String($0) }
        
        completedExpressionString = "\(stringArrayNumbers[0]) \(getSignString()) \(stringArrayNumbers[1]) = \(stringArrayNumbers[2])"
        
        underScorePosition = Int.random(in: 0..<3)
        stringArrayNumbers[underScorePosition] = "_"
        numToFind = arrayNumbers[underScorePosition]
        numToFindDigits = numToFind.digits
            
        numberOfDigits = arrayNumbers[underScorePosition].digitCount
        if numberOfDigits > 1 {
            for _ in 2...numberOfDigits {
                stringArrayNumbers[underScorePosition] += "_"
            }
        }
    }
    
    private func setNumbers() {
        if let operation = BinaryOperation(enabled: operationsAvailable) {
            binaryOperation = operation
        }
        guard let difficultyLevel = binaryOperation?.rangesForDifficulty(Difficulty(rawValue: 0) ?? .easy) else { return }
        guard let sign = binaryOperation?.rawValue else { return }
        self.sign = sign
        let (range1, range2) = difficultyLevel
        firstNum = Int.random(in: range1)
        secondNum = Int.random(in: range2)
        guard let resultNum = (binaryOperation?.apply(firstNum, secondNum)) else { return }
        self.resultNum = resultNum
        print("Answer to your question: \(resultNum)")
    }
    
    public func getColorOperation() -> UIColor {
        switch binaryOperation {
        case .Subtraction, .Multiplication:
            return Colors.red
        case .Addition:
            return Colors.green
        case .Division:
            return Colors.pink
        default:
            return .black
        }
    }
    
    public func showExpressionText() -> String {
        let signString = getSignString()
        let expression = "\(stringArrayNumbers[0]) \(signString) \(stringArrayNumbers[1]) = \(stringArrayNumbers[2])"
        expressionString = expression
        return expression
    }
    
    public func enterNumber(number: String) -> String {
        var answerNumbers = stringArrayNumbers
        answerNumber = answerNumbers[underScorePosition]
        
        let modifiedString1 = answerNumber.replace(target: " ", withString: "")
        let modifiedString2 = modifiedString1.replace(target: "_", withString: "")
        
        answerNumber = modifiedString2
        answerNumber += number
        
        if numberOfDigits > 1 {
            for _ in 2...numberOfDigits {
                answerNumber += "_"
            }
        }
        
        answerNumbers[underScorePosition] = answerNumber
        let expression = "\(answerNumbers[0]) \(getSignString()) \(answerNumbers[1]) = \(answerNumbers[2])"
        return expression
    }
    
    public func getSignString() -> String {
        return sign
    }
    
    public func checkEnteredNumber(number: String) -> ResultEnteredNumber {
        if numToFindDigits[0] == Int(number) {
            numToFindDigits.removeFirst()
            if numToFindDigits.isEmpty {
                return .right
            }
            
            let modifiedString = stringArrayNumbers[underScorePosition].replace(target: "_", withString: "")
            stringArrayNumbers[underScorePosition] = modifiedString
            stringArrayNumbers[underScorePosition] += number
            
            if numberOfDigits > 1 {
                for _ in 2...numberOfDigits {
                    stringArrayNumbers[underScorePosition] += "_"
                }
            }
            numberOfDigits -= 1
            return .toContinue
        }
        return .wrong
    }
}

