//
//  InputTextField.swift
//  Lumenshine
//
//  Created by Soneso on 19/09/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit

class InputTextField: UITextField {
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    private func setup() {
        borderStyle = .none
        layer.borderWidth = 0.33
        layer.borderColor = Stylesheet.color(.borderGray).cgColor
        font = R.font.encodeSansSemiBold(size: 10)
        textColor = Stylesheet.color(.lightBlack)
        backgroundColor = Stylesheet.color(.white)
        
        if let placeholder = placeholder {
            attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [.foregroundColor : Stylesheet.color(.lightBlack)])
        }
        
        leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: frame.height))
        leftViewMode = UITextFieldViewMode.always
        
        snp.makeConstraints { (make) in
            make.height.greaterThanOrEqualTo(30)
        }
    }
}
