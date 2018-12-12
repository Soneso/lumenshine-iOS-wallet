//
//  UIColor+Utils.swift
//  Lumenshine
//
//  Created by Soneso GmbH on 12/12/2018.
//  Munich, Germany
//  web: https://soneso.com
//  email: hi@soneso.com
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit

extension UIColor {
    
    /**
     * Initializer for creating colors out of hex strings (#RRGGBBAA format).
     * - parameter hexString: Hex representation string. # prefix is optional.
     * - returns: New UIColor instance if the hex string is valid, or nil.
     */
    public convenience init?(hexString: String?) {
        guard let hexString = hexString else { return nil }
        let hexRepresentation = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        guard (hexRepresentation.hasPrefix("#") && hexRepresentation.count == 9) ||
            (!hexRepresentation.hasPrefix("#") && hexRepresentation.count == 8)  else {
                return nil
        }
        
        let r, g, b, a: CGFloat
        let scanner = Scanner(string: hexRepresentation)
        
        if hexString.hasPrefix("#") {
            scanner.scanLocation = 1
        }
        
        var hexNumber: UInt64 = 0
        
        if scanner.scanHexInt64(&hexNumber) {
            r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
            g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
            b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
            a = CGFloat(hexNumber & 0x000000ff) / 255
            
            self.init(red: r, green: g, blue: b, alpha: a)
            return
        }
        
        return nil
    }
    
    /**
     * #RRGGBBAA format
     */
    func toHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rgba: UInt64 = (UInt64)(r*255)<<24 | (UInt64)(g*255)<<16 | (UInt64)(b*255)<<8 | (UInt64)(a*255)
        
        return String(format:"#%08x", rgba)
    }
}
