//
//  LSTextAttachment.swift
//  Lumenshine
//
//  Created by Elekes Istvan on 16/11/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation
import UIKit.NSTextAttachment

class LSTextAttachment: NSTextAttachment {
    
    let additionalInfo: String
    
    init(info: String) {
        self.additionalInfo = info
        super.init(data: nil, ofType: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
