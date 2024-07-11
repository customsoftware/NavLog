import UIKit

enum TurnDirection {
    case left
    case right
    case notSet
    
    var direction: String {
        let retString: String
        switch self {
        case .left:
            retString = "Turn Left"
        case .right:
            retString = "Turn Right"
        case .notSet:
            retString = ""
        }
        
        return retString
    }
}

// Hy = Your Heading
// Hd = Desired Heading

func evaluateTurn(Hy: Double, Hd: Double) -> TurnDirection {
    var retValue: TurnDirection = .notSet
    
    if Hy > 180,
       Hd <= 180 {
        
        // Opposite sides of the rose
        if (Hy - Hd) <= 180 {
            retValue = .left
        } else {
            retValue = .right
        }
        
    } else if Hd > 180,
              Hy <= 180 {
        
        // Opposite sides of the rose
        if (Hd - Hy) <= 180 {
            retValue = .right
        } else {
            retValue = .left
        }
    } else {
        // Same side of the rose
        if Hy < Hd {
            retValue = .right
        } else {
            retValue = .left
        }
    }
    
    return retValue
}

print(" 1. \(evaluateTurn(Hy: 20, Hd: 80).direction) Right")
print(" 3. \(evaluateTurn(Hy: 20, Hd: 110).direction) Right")
print(" 6. \(evaluateTurn(Hy: 250, Hd: 20).direction) Right")
print(" 7. \(evaluateTurn(Hy: 350, Hd: 40).direction) Right")
print(" 9. \(evaluateTurn(Hy: 90, Hd: 110).direction) Right")
print("11, \(evaluateTurn(Hy: 100, Hd: 250).direction) Right")
print("13. \(evaluateTurn(Hy: 140, Hd: 320).direction) Right")
print("15. \(evaluateTurn(Hy: 220, Hd: 250).direction) Right")
print("17. \(evaluateTurn(Hy: 220, Hd: 350).direction) Right")
print("19. \(evaluateTurn(Hy: 350, Hd: 360).direction) Right")
print(" ")
print(" 2. \(evaluateTurn(Hy: 80, Hd: 20).direction) Left")
print(" 4. \(evaluateTurn(Hy: 120, Hd: 10).direction) Left")
print(" 5. \(evaluateTurn(Hy: 20, Hd: 250).direction) Left")
print(" 8. \(evaluateTurn(Hy: 20, Hd: 300).direction) Left")
print("10. \(evaluateTurn(Hy: 120, Hd: 90).direction) Left")
print("12. \(evaluateTurn(Hy: 250, Hd: 100).direction) Left")
print("14. \(evaluateTurn(Hy: 320, Hd: 140).direction) Left")
print("16. \(evaluateTurn(Hy: 220, Hd: 200).direction) Left")
print("18. \(evaluateTurn(Hy: 350, Hd: 220).direction) Left")
print("20. \(evaluateTurn(Hy: 360, Hd: 350).direction) Left")
