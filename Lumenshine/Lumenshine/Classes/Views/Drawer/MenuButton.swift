//
//  MenuButton.swift
//  Lumenshine
//
//  Created by Soneso GmbH on 12/12/2018.
//  Munich, Germany
//  web: https://soneso.com
//  email: hi@soneso.com
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit

class MenuButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        tintColor = Stylesheet.color(.blue)
        imageView?.contentMode = .scaleAspectFit
        setImage(R.image.iconMenu(), for: .normal)
        imageEdgeInsets = UIEdgeInsetsMake(0, 11.0, 0, -11.0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var showsMenu: Bool! {
        didSet {
            //setMenuStateChanged()
        }
    }
    
    private func setMenuStateChanged() {
        if showsMenu {
            setImage(R.image.iconMenu(), for: .normal)
        } else {
            setImage(R.image.arrowLeft(), for: .normal)
        }
    }
}
