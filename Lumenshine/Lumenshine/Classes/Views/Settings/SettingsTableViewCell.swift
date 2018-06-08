//
//  SettingsTableViewCell.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 6/6/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit

class SettingsTableViewCell: UITableViewCell {
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
    }
}
