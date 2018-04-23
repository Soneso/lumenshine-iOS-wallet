//
//  RegistrationTableViewCell.swift
//  Stellargate
//
//  Created by Istvan Elekes on 4/21/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material

protocol RegistrationTableCellProtocol {
    func setPlaceholder(_ placeholder: String?)
}

class RegistrationTableViewCell: UITableViewCell {
    
    fileprivate let textField = TextField()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        
        selectionStyle = .none
//        textField.isSecureTextEntry = true
        
        textField.dividerActiveColor = Stylesheet.color(.cyan)
        textField.placeholderActiveColor = Stylesheet.color(.cyan)
        
        contentView.addSubview(textField)
        textField.snp.makeConstraints { (make) in
            make.top.equalTo(0)
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.bottom.equalTo(0)
        }
    }
}

extension RegistrationTableViewCell: RegistrationTableCellProtocol {
    func setPlaceholder(_ placeholder: String?) {
        textField.placeholder = placeholder
    }
    
}
