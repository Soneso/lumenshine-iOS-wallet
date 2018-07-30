//
//  UIView+Snapshot.swift
//  Lumenshine
//
//  Created by Razvan Chelemen on 28/07/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit

extension UIView {
    func toImage() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)
        
        drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
}
