//
//  CellRegularLabel.swift
//  Lumenshine
//
//  Created by Soneso on 08/10/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit

class CellRegularLabel: UILabel {
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    private func setup() {
        font = R.font.encodeSansRegular(size: 14)
        textColor = Stylesheet.color(.lightBlack)
    }
}
