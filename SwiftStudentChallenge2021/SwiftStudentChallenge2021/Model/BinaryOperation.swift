import Foundation

struct OperationsEnabled {
    var addition = true
    var subtraction = true
    var multiplication = true
    var division = true
}

enum Difficulty: Int {
    case easy = 0
    case intermediate = 1
    case difficult = 2
}

enum BinaryOperation: String {
    
    case Addition = "+"
    case Subtraction = "-"
    case Multiplication = "×"
    case Division = "÷"
    
    init?(enabled: OperationsEnabled) {
        let all: [(BinaryOperation, Bool)] = [(.Addition, enabled.addition), (.Subtraction, enabled.subtraction), (.Multiplication, enabled.multiplication), (.Division, enabled.division)]
        let avail = all.compactMap { (op, on) in on == true ? op : nil }
        if avail.isEmpty {
            return nil
        }
        else {
            let index = Int(arc4random_uniform(UInt32(avail.count)))
            self = avail[index]
        }
    }
    
    func rangesForDifficulty(_ difficulty: Difficulty) -> (ClosedRange<Int>, ClosedRange<Int>) {
        switch self {
            
        case .Addition:
            switch difficulty {
            case .easy: return (1...10, 1...10)
            case .intermediate: return (10...100, 1...100)
            case .difficult: return (109...999, 109...999)
            }
            
        case .Subtraction:
            switch difficulty {
            case .easy: return (5...10, 1...5)
            case .intermediate: return (50...100, 1...50)
            case .difficult:  return (109...999, 50...109)
            }
            
        case .Multiplication:
            switch difficulty {
            case .easy: return (1...10, 2...4)
            case .intermediate: return (1...50, 3...7)
            case .difficult: return (10...100, 4...15)
            }

        case .Division:
            switch difficulty {
            case .easy:
                var number1 = Int.random(in: 1...10)
                let randomDivisor = Int.random(in: 2...3)
                number1 *= randomDivisor
                let number2 = number1 / randomDivisor
                return (number1...number1, number2...number2)
            case .intermediate:
                var number1 = Int.random(in: 10...50)
                let randomDivisor = Int.random(in: 2...5)
                number1 *= randomDivisor
                let number2 = number1 / randomDivisor
                return (number1...number1, number2...number2)
            case .difficult:
                var number1 = Int.random(in: 50...200)
                let randomDivisor = Int.random(in: 2...7)
                number1 *= randomDivisor
                let number2 = number1 / randomDivisor
                return (number1...number1, number2...number2)
            }
        }
    }
    
    func apply(_ number1: Int, _ number2: Int) -> Int {
        switch self {
        case .Addition:
            return number1 + number2
        case .Subtraction:
            return number1 - number2
        case .Multiplication:
            return number1 * number2
        case .Division:
            return number1 / number2
        }
    }
}

