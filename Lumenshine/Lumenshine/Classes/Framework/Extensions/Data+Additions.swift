//
//  Data+Additions.swift
//  Lumenshine
//
//  Created by Razvan Chelemen on 14/06/2019.
//  Copyright © 2019 Soneso. All rights reserved.
//

import Foundation
import UIKit
import stellarsdk

//TODO: Remove this if making the sdk extensions public

extension Data {
    
    internal init(hex: String) {
        self.init(bytes: Array<UInt8>(hex: hex))
    }
    
    internal var bytes: Array<UInt8> {
        return Array(self)
    }
    
    func toHexString() -> String {
        return bytes.toHexString()
    }
    
    func sha256() -> Data {
        return Data(bytes: Digest.sha256(bytes))
    }
    
}

extension Array {
    init(reserveCapacity: Int) {
        self = Array<Element>()
        self.reserveCapacity(reserveCapacity)
    }
    
    var slice: ArraySlice<Element> {
        return self[self.startIndex..<self.endIndex]
    }
}

extension Array where Element == UInt8 {
    
    init(hex: String) {
        self.init(reserveCapacity: hex.unicodeScalars.lazy.underestimatedCount)
        var buffer: UInt8?
        var skip = hex.hasPrefix("0x") ? 2 : 0
        for char in hex.unicodeScalars.lazy {
            guard skip == 0 else {
                skip -= 1
                continue
            }
            guard char.value >= 48 && char.value <= 102 else {
                removeAll()
                return
            }
            let v: UInt8
            let c: UInt8 = UInt8(char.value)
            switch c {
            case let c where c <= 57:
                v = c - 48
            case let c where c >= 65 && c <= 70:
                v = c - 55
            case let c where c >= 97:
                v = c - 87
            default:
                removeAll()
                return
            }
            if let b = buffer {
                append(b << 4 | v)
                buffer = nil
            } else {
                buffer = v
            }
        }
        if let b = buffer {
            append(b)
        }
    }
    
    func toBase64() -> String? {
        return Data(bytes: self).base64EncodedString()
    }
    
    init(base64: String) {
        self.init()
        
        guard let decodedData = Data(base64Encoded: base64) else {
            return
        }
        
        append(contentsOf: decodedData.bytes)
    }
    
    func toHexString() -> String {
        return `lazy`.reduce("") {
            var s = String($1, radix: 16)
            if s.count == 1 {
                s = "0" + s
            }
            return $0 + s
        }
    }
    
    func sha256() -> [Element] {
        return Digest.sha256(self)
    }
    
}

extension String {
    
    var bytes: Array<UInt8> {
        return data(using: String.Encoding.utf8, allowLossyConversion: true)?.bytes ?? Array(utf8)
    }
    
    func sha256() -> String {
        return bytes.sha256().toHexString()
    }
}

extension Range where Bound == String.Index {
    var nsRange: NSRange {
        return NSRange(location: self.lowerBound.encodedOffset, length: self.upperBound.encodedOffset - self.lowerBound.encodedOffset)
    }
}

extension Array where Element == Range<String.Index> {
    
    var nsRanges: [NSRange] {
        var nsRanges = [NSRange]()
        
        for range in self {
            nsRanges.append(range.nsRange)
        }
        
        return nsRanges
    }

}

