//
//  IconButton.swift
//  Lumenshine
//
//  Created by Razvan Chelemen on 14/06/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material

class IconButton: FlatButton {
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var iconLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        pulseColor = UIColor.white
        pulseOpacity = 0.3
        
        let view = Bundle.main.loadNibNamed("IconView", owner: self, options: nil)![0] as! UIView
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
    }

}
