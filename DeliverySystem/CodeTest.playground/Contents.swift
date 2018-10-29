import UIKit

var str = "Hello, playground"


let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

var randomTrackingNumber = ""

for _ in 0...4 {
    if let letter = letters.randomElement() {
        randomTrackingNumber += "\(letter)"
    }
}

print(randomTrackingNumber)

let randomOffset = Int(arc4random_uniform(UInt32(letters.count)))
let dex = letters.index(letters.startIndex, offsetBy: randomOffset)
print(letters[dex])



extension String {
    func getRandomCharFrom(index i: Int) -> Character?{
        var cur = 0
        var returnC: Character?
        
        for letter in self {
            if cur == i {
                returnC = letter
            }
            cur+=1
        }
        return returnC
    }
}

let randomIndex = Int(arc4random_uniform(UInt32(letters.count)))
print(letters.getRandomCharFrom(index: randomIndex)!)
