//
//  Stylesheet.swift
//  jupiter
//
//  Created by Istvan Elekes on 3/2/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit

enum FontStyle {
    case header1
    
    case title1
    case title2
    case title3
    
    case caption1
    case caption2
    
    case body
    
    case headline
    case subhead
    
    case callout
    case footnote
    
    case medium(CGFloat)
    case bold(CGFloat)
    case mediumItalic(CGFloat)
}

enum ColorStyle {
    case clear
    case lightGray
    case darkGray
    case green
    case orange
    case blue
    case red
    case cyan
    
    case white
    case whiteWith(alpha: CGFloat)
    case black
    case blackWith(alpha: CGFloat)
}

struct Stylesheet {
    
    private struct CustomFont {
        @available(iOS 11.0, *)
        static let largeTitle = UIFont.preferredFont(forTextStyle: .largeTitle)
        
        static let title1 = UIFont.preferredFont(forTextStyle: .title1)
        static let title2 = UIFont.preferredFont(forTextStyle: .title2)
        static let title3 = UIFont.preferredFont(forTextStyle: .title3)
        
        public static let headline = UIFont.preferredFont(forTextStyle: .headline)
        public static let subheadline = UIFont.preferredFont(forTextStyle: .subheadline)
        
        public static let body = UIFont.preferredFont(forTextStyle: .body)
        public static let callout = UIFont.preferredFont(forTextStyle: .callout)
        public static let footnote = UIFont.preferredFont(forTextStyle: .footnote)
        
        static let caption1 = UIFont.preferredFont(forTextStyle: .caption1)
        static let caption2 = UIFont.preferredFont(forTextStyle: .caption2)
    }
    
    static func font(_ style: FontStyle) -> UIFont {
        switch style {
        case .header1:
            if #available(iOS 11.0, *) {
                return CustomFont.largeTitle
            } else {
                return CustomFont.title1
            }
        case .title1:
            return CustomFont.title1
        case .title2:
            return CustomFont.title2
        case .title3:
            return CustomFont.title3
        case .caption1:
            return CustomFont.caption1
        case .caption2:
            return CustomFont.caption2
        case .body:
            return CustomFont.body
        case .headline:
            return CustomFont.headline
        case .subhead:
            return CustomFont.subheadline
        case .callout:
            return CustomFont.callout
        case .footnote:
            return CustomFont.footnote
        case .medium(let size):
            return UIFont.systemFont(ofSize: size)
        case .bold(let size):
            return UIFont.boldSystemFont(ofSize: size)
        case .mediumItalic(let size):
            return UIFont.italicSystemFont(ofSize: size)
        }
    }
    
    static func color(_ style: ColorStyle) -> UIColor {
        switch style {
        case .lightGray:
            return UIColor.lightGray
        case .darkGray:
            return UIColor.darkGray
        case .green:
            return UIColor.green
        case .orange:
            return UIColor.orange
        case .blue:
            return UIColor.blue
        case .red:
            return UIColor.red
        case .cyan:
            return UIColor(red: 7/255.0, green: 162/255.0, blue: 204/255.0, alpha: 1.0)
        case .clear:
            return UIColor.clear
        case .white:
            return UIColor.white
        case .black:
            return UIColor.black
        case .blackWith(let alpha):
            return UIColor.black.withAlphaComponent(alpha)
        case .whiteWith(let alpha):
            return UIColor.white.withAlphaComponent(alpha)
        }
    }
}

