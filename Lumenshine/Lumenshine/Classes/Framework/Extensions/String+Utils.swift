//
//  String+Utils.swift
//  Lumenshine
//
//  Created by Razvan Chelemen on 27/05/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation

extension String  {
    
    func isEmail() -> Bool {
        let sRegex = "(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])"

        return NSPredicate(format: "SELF MATCHES[c] %@", sRegex).evaluate(with: self)
    }
    
    func isMobilePhone() -> Bool {
        let sRegex = "^[+]?[0-9]{11,16}$"
        
        return NSPredicate(format: "SELF MATCHES[c] %@", sRegex).evaluate(with: self)
    }
    
    func isValidPassword() -> Bool {
        
        if self.count < 9 {
            return false
        }
        
        let lowerCase = CharacterSet.lowercaseLetters
        let upperCase = CharacterSet.uppercaseLetters
        let decimalDigits = CharacterSet.decimalDigits
        
        if self.rangeOfCharacter(from: lowerCase) == nil {
            return false
        }
        
        if self.rangeOfCharacter(from: upperCase) == nil {
            return false
        }
        
        if self.rangeOfCharacter(from: decimalDigits) == nil {
            return false
        }
        
        return true
        //let sRegex = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)[A-Za-z\\d]{9,}"
        // with special character
        //let regex = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[$@$!%*?&])[A-Za-z\\d$@$!%*?&]{8,}"
        
        //return NSPredicate(format: "SELF MATCHES %@", sRegex).evaluate(with: self)
    }
}
