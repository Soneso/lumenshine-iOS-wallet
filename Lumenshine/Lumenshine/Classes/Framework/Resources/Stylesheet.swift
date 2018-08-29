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
    case gray
    case lightGray
    case darkGray
    case green
    case orange
    case blue
    case lightBlue
    case darkBlue
    case red
    case yellow
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
        case .gray:
            return UIColor(red: 168/255.0, green: 168/255.0, blue: 168/255.0, alpha: 1.0)
        case .lightGray:
            return UIColor(red: 225/255.0, green: 225/255.0, blue: 225/255.0, alpha: 1.0)
        case .darkGray:
            return UIColor(red: 137/255.0, green: 137/255.0, blue: 137/255.0, alpha: 1.0)
        case .green:
            return UIColor(red: 145/255.0, green: 199/255.0, blue: 74/255.0, alpha: 1.0)
        case .orange:
            return UIColor.orange
        case .darkBlue:
            return UIColor(red: 51/255.0, green: 122/255.0, blue: 189/255.0, alpha: 1.0)
        case .blue:
            return UIColor(red: 57/255.0, green: 172/255.0, blue: 225/255.0, alpha: 1.0)
        case .lightBlue:
            return UIColor(red: 178/255.0, green: 231/255.0, blue: 255/255.0, alpha: 1.0)
        case .red:
            return UIColor(red: 236/255.0, green: 28/255.0, blue: 35/255.0, alpha: 1.0)
        case .yellow:
            return UIColor.yellow
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

