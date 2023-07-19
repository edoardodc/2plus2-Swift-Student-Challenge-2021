import Foundation

public extension Int {
    
    var usefulDigitCount: Int {
        get {
            var count = 0
            for digitOrder in 0..<self.digitCount {
                let digit = self % (Int(truncating: pow(10, digitOrder + 1) as NSDecimalNumber))
                    / Int(truncating: pow(10, digitOrder) as NSDecimalNumber)
                if isUseful(digit) { count += 1 }
            }
            return count
        }
    }
    
    var digitCount: Int {
        get {
            return numberOfDigits(in: self)
        }
    }
    
    private func isUseful(_ digit: Int) -> Bool {
        return (digit != 0) && (self % digit == 0)
    }

    private func numberOfDigits(in number: Int) -> Int {
        if number < 10 && number >= 0 || number > -10 && number < 0 {
            return 1
        } else {
            return 1 + numberOfDigits(in: number/10)
        }
    }
}

public extension Float {
    static func random(lower: Float = 0, _ upper: Float = 100) -> Float {
        return (Float(arc4random()) / Float(0xFFFFFFFF)) * (upper - lower) + lower
    }
}

