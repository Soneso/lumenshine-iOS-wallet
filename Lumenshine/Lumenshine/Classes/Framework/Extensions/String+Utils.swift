//
//  String+Utils.swift
//  Lumenshine
//
//  Created by Soneso GmbH on 12/12/2018.
//  Munich, Germany
//  web: https://soneso.com
//  email: hi@soneso.com
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation
import UIKit

enum MemoTextValidationResult {
    case Valid
    case InvalidEncoding
    case InvalidLength
}

enum StringConstants: String {
    case openParenthesis = "("
    case closeParenthesis = ")"
}

enum CharacterConstants: Character {
    case emptySpace = " "
}

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
    }
    
    func isValidName () -> Bool {
        
        if self.trimmed.count < 2 {
            return false
        }
        
        let decimalDigits = CharacterSet.decimalDigits
        
        if self.rangeOfCharacter(from: decimalDigits) != nil {
            return false
        }
        return true
    }
    
    func isMandatoryValid() -> Bool {
        let sRegex = "^\\s*$"
        
        return !NSPredicate(format: "SELF MATCHES[c] %@", sRegex).evaluate(with: self)
    }
    
    func isBase64Valid() -> Bool {
        return NSData(base64Encoded: self) != nil
    }
    
    func isAmountSufficient(forBalance balance: String) -> Bool {
        if let availableFunds = CoinUnit(balance), let requestedFunds = CoinUnit(self) {
            if (availableFunds.isLess(than: requestedFunds) || requestedFunds == 0) {
                return false
            }
            
            return true
        }
        
        return false
    }

    func isMemoTextValid(limitNrOfBytes: Int) -> MemoTextValidationResult {
        var isASCIIEncoded: Bool = false
        var isUTF8Encoded: Bool = false
        var nonASCIIFound: Bool = false
        var isTextLengthValid: Bool = false
        
        for scalar in self.unicodeScalars {
            if (!scalar.isASCII) {
                nonASCIIFound = true
                break
            }
        }
        
        if (!nonASCIIFound) {
            isASCIIEncoded = true
            
            var byteCount: Int = 0
            for _ in String(self) {
                byteCount += 1
            }
            
            if (byteCount <= limitNrOfBytes) {
                isTextLengthValid = true
            }
        }
        
        if self.utf8.count == 0 && isASCIIEncoded == false {
            return MemoTextValidationResult.InvalidEncoding
        }
        
        if isASCIIEncoded == false {
            isUTF8Encoded = true
            var byteArray = [UInt8]()
            for char in self.utf8{
                byteArray += [char]
            }
            
            if byteArray.count <= limitNrOfBytes {
                isTextLengthValid = true
            }
        }
        
        if !isASCIIEncoded && !isUTF8Encoded {
            return MemoTextValidationResult.InvalidEncoding
        }

        if !isTextLengthValid {
            return MemoTextValidationResult.InvalidLength
        }
        
        return MemoTextValidationResult.Valid
    }
    
    func isMemoIDValid() -> Bool {
        if UInt64(self) != nil {
            return true
        }
        
        return false
    }
    
    func isMemoHashValid() -> Bool {
        var byteArray = [UInt8]()
        for char in self.utf8{
            byteArray += [char]
        }
        
        if byteArray.count == 32 {
            return true
        }
        
        return false
    }
    
    func isMemoReturnValid() -> Bool {
        return isMemoHashValid()
    }
    
    func isFederationAddress() -> Bool {
        return self.range(of: "*") != nil
    }
    
    func isAssetCodeValid() -> Bool {
        let sRegex = "^([a-zA-Z0-9]){1,12}$"
        
        return NSPredicate(format: "SELF MATCHES[c] %@", sRegex).evaluate(with: self)
    }
    
    func isNumeric() -> Bool {
        let sRegex = "^(([0-9]\\.)|([1-9][0-9]*\\.*))[0-9]*$"
        
        return NSPredicate(format: "SELF MATCHES[c] %@", sRegex).evaluate(with: self)
    }
    
    func getAssetCode() -> String? {
        let separatedStrings = self.split(separator: CharacterConstants.emptySpace.rawValue)
        for subString in separatedStrings {
            if subString.hasPrefix(StringConstants.openParenthesis.rawValue) && subString.hasSuffix(StringConstants.closeParenthesis.rawValue) {
                var assetCode = subString
                assetCode.removeFirst()
                assetCode.removeLast()
                
                return !assetCode.isEmpty ? String(assetCode) : nil
            }
        }
        
        return nil
    }
    
    func extend(prefix: String, count: Int = 1) -> String {
        var extended = self
        for _ in 0...count {
            extended = prefix + extended
        }
        return extended
    }
    
    func getSize(usingFont font: UIFont) -> CGSize {
        let fontAttributes = [NSAttributedString.Key.font: font]
        return self.size(withAttributes: fontAttributes)
    }
    
    func ranges(of substring: String, options: CompareOptions = [], locale: Locale? = nil) -> [Range<Index>] {
        var ranges: [Range<Index>] = []
        while let range = self.range(of: substring, options: options, range: (ranges.last?.upperBound ?? self.startIndex)..<self.endIndex, locale: locale) {
            ranges.append(range)
        }
        
        return ranges
    }
}
