//
//  Array+Shuffle.swift
//  Stellargate
//
//  Created by Istvan Elekes on 5/11/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation

extension Array {
    
    func shuffled() -> Array {
        var shuffled = [Element]()
        var items = Array(self)
        
        for _ in 0..<items.count {
            let rand = Int(arc4random_uniform(UInt32(items.count)))
            shuffled.append(items[rand])
            items.remove(at: rand)
        }
        return shuffled
    }
}
