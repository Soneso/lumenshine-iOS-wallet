//
//  UIView+RoundedCorners.swift
//  Lumenshine
//
//  Created by Soneso on 26/10/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit

extension UIView {
    func roundCorners(_ corners: CACornerMask, radius: CGFloat) {
        if #available(iOS 11, *) {
            self.layer.cornerRadius = radius
            self.layer.maskedCorners = corners
        } else {
            var cornerMask = UIRectCorner()
            if(corners.contains(.layerMinXMinYCorner)){
                cornerMask.insert(.topLeft)
            }
            
            if(corners.contains(.layerMaxXMinYCorner)){
                cornerMask.insert(.topRight)
            }
            
            if(corners.contains(.layerMinXMaxYCorner)){
                cornerMask.insert(.bottomLeft)
            }
            
            if(corners.contains(.layerMaxXMaxYCorner)){
                cornerMask.insert(.bottomRight)
            }
            
            let path = UIBezierPath(roundedRect: self.layer.bounds, byRoundingCorners: cornerMask, cornerRadii: CGSize(width: radius, height: radius))
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            self.layer.masksToBounds = true
            self.layer.mask = mask
        }
    }
}
