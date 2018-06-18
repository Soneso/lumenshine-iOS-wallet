//
//  MenuTableViewCell.swift
//  jupiter
//
//  Created by Istvan Elekes on 3/1/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit

class MenuTableViewCell: UITableViewCell {
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        textLabel?.textColor = Stylesheet.color(.white)
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
