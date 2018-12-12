//
//  RandomBytesSequence.swift
//  Lumenshine
//
//  Created by Soneso GmbH on 12/12/2018.
//  Munich, Germany
//  web: https://soneso.com
//  email: hi@soneso.com
//  Copyright © 2018 Soneso. All rights reserved.
//

import Darwin

struct RandomBytesSequence: Sequence {
    let size: Int
    
    func makeIterator() -> AnyIterator<UInt8> {
        var count = 0
        return AnyIterator<UInt8>.init({ () -> UInt8? in
            if count >= self.size {
                return nil
            }
            count = count + 1
            return UInt8(arc4random_uniform(UInt32(UInt8.max) + 1))
        })
    }
}
