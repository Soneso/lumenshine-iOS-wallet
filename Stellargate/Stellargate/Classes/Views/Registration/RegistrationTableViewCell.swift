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
    func setText(_ text: String?)
}

typealias TextChangedClosure = (_ text:String) -> (Void)

class RegistrationTableViewCell: UITableViewCell {
    
    fileprivate let textField = TextField()
    var textEditingCallback: TextChangedClosure?
    
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
        textField.placeholderAnimation = .hidden
        textField.addTarget(self, action: #selector(editingDidChange(_:)), for: .editingChanged)
        
        contentView.addSubview(textField)
        textField.snp.makeConstraints { (make) in
            make.top.equalTo(10)
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.bottom.equalTo(-10)
        }
    }
    
    @objc
    func editingDidChange(_ textField: TextField) {
        guard let text = textField.text else {
            return
        }
        guard let callback = textEditingCallback else {
            return
        }
        callback(text)
    }

}

extension RegistrationTableViewCell: RegistrationTableCellProtocol {
    func setPlaceholder(_ placeholder: String?) {
        textField.placeholder = placeholder
    }
    
    func setText(_ text: String?) {
        textField.text = text
    }
}
