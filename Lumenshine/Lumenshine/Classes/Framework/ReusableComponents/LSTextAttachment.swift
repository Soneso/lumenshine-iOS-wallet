//
//  LSTextAttachment.swift
//  Lumenshine
//
//  Created by Soneso GmbH on 12/12/2018.
//  Munich, Germany
//  web: https://soneso.com
//  email: hi@soneso.com
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
