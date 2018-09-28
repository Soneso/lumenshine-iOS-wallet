//
//  HelpTableViewCell.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 9/26/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit

protocol HelpCellProtocol {
    func setText(_ text: String?)
    func setDetail(_ detail: String?)
    func setImage(_ image: UIImage?)
}

class HelpTableViewCell: UITableViewCell {
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = UIEdgeInsetsInsetRect(contentView.frame, UIEdgeInsetsMake(0, 15, 0, 15))
    }
    
    func commonInit() {
        textLabel?.textColor = Stylesheet.color(.lightBlack)
        textLabel?.font = R.font.encodeSansSemiBold(size: 13)
        
        detailTextLabel?.textColor = Stylesheet.color(.lightBlack)
        detailTextLabel?.font = R.font.encodeSansSemiBold(size: 13)
        
        textLabel?.numberOfLines = 0
        
        contentView.backgroundColor = Stylesheet.color(.white)
        backgroundColor = .clear
        
        let selection = UIView()
        selection.backgroundColor = Stylesheet.color(.lightGray)
        selectedBackgroundView = selection
    }
}

extension HelpTableViewCell: HelpCellProtocol {
    func setText(_ text: String?) {
        textLabel?.text = text
    }
    
    func setDetail(_ detail: String?) {
        detailTextLabel?.text = detail
        if let d = detail, !d.isEmpty {
            textLabel?.font = R.font.encodeSansBold(size: 13)
        }
    }
    
    func setImage(_ image: UIImage?) {
        imageView?.image = image?.tint(with: Stylesheet.color(.blue))
    }
}
