//
//  Sequence+Utils.swift
//  Lumenshine
//
//  Created by Razvan Chelemen on 26/07/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation

public extension Sequence where Element: Equatable {
    var uniqueElements: [Element] {
        return self.reduce(into: []) {
            uniqueElements, element in
            
            if !uniqueElements.contains(element) {
                uniqueElements.append(element)
            }
        }
    }
}
