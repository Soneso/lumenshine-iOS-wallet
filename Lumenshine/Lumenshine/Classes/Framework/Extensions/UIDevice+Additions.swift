//
//  UIDevice+Additions.swift
//  Lumenshine
//
//  Created by Soneso GmbH on 12/12/2018.
//  Munich, Germany
//  web: https://soneso.com
//  email: hi@soneso.com
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit

@objc enum ScreenType: Int {
    case iPhone4
    case iPhone5
    case iPhone6
    case iPhone6Plus
    case iPhoneX
    case iPad9Inch
    case iPad12Inch
    case unknown
}

extension UIDevice {
    var iPhone: Bool {
        return UIDevice().userInterfaceIdiom == .phone
    }
    
    var screenType: ScreenType {
        if (iPhone) {
            switch UIScreen.main.nativeBounds.height {
            case 960:
                return .iPhone4
            case 1136:
                return .iPhone5
            case 1334:
                return .iPhone6
            case 2208:
                return .iPhone6Plus
            case 2436:
                return .iPhoneX
            default:
                return .unknown
            }
        } else {
            switch UIScreen.main.nativeBounds.height {
            case 2048:
                return .iPad9Inch
            case 2732:
                return .iPad12Inch
            default:
                return .unknown
            }
        }
    }
}

