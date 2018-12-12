//
//  Array+Shuffle.swift
//  Lumenshine
//
//  Created by Soneso GmbH on 12/12/2018.
//  Munich, Germany
//  web: https://soneso.com
//  email: hi@soneso.com
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
