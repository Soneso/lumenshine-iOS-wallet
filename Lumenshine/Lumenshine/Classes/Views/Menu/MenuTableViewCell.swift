//
//  MenuTableViewCell.swift
//  Lumenshine
//
//  Created by Soneso GmbH on 12/12/2018.
//  Munich, Germany
//  web: https://soneso.com
//  email: hi@soneso.com
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit

class MenuTableViewCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        textLabel?.textColor = Stylesheet.color(.white)
        textLabel?.font = R.font.encodeSansSemiBold(size: 13.5)
        backgroundColor = Stylesheet.color(.clear)
        imageView?.tintColor = Stylesheet.color(.white)
        let selection = UIView()
        selection.backgroundColor = Stylesheet.color(.whiteWith(alpha: 0.3))
        selectedBackgroundView = selection
    }
}

extension MenuTableViewCell: MenuCellProtocol {
    func setText(_ text: String?) {
        textLabel?.text = text
    }
    
    func setImage(_ image: UIImage?) {
        imageView?.image = image
    }
}
