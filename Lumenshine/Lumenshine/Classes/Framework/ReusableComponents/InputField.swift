//
//  InputField.swift
//  Lumenshine
//
//  Created by Soneso GmbH on 12/12/2018.
//  Munich, Germany
//  web: https://soneso.com
//  email: hi@soneso.com
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material

class InputField: UIView {
    
    let textField = TextField()
    let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonInit() {
        
        label.adjustsFontSizeToFitWidth = true
        label.font = R.font.encodeSansRegular(size: 14)
        label.textColor = Stylesheet.color(.lightBlack)
        
        addSubview(label)
        label.snp.makeConstraints { make in
            make.top.left.bottom.equalToSuperview()
            make.width.equalTo(60)
        }
        
        textField.keyboardType = .decimalPad
        textField.placeholder = R.string.localizable.position()
        textField.placeholderAnimation = .hidden
//        textField.placeholderActiveColor = Stylesheet.color(.lightBlack)
//        textField.placeholderNormalColor = Stylesheet.color(.lightBlack)
        textField.font = R.font.encodeSansRegular(size: 14)
        textField.textColor = Stylesheet.color(.lightBlack)
        textField.dividerActiveColor = Stylesheet.color(.gray)
        
        addSubview(textField)
        textField.snp.makeConstraints { make in
            make.top.right.bottom.equalToSuperview()
            make.left.equalTo(label.snp.right).offset(5)
            make.width.equalTo(50)
        }
    }
    
    func makeInvalid(_ invalid: Bool) {
        if invalid {
            textField.dividerActiveColor = Stylesheet.color(.red)
            textField.dividerNormalColor = Stylesheet.color(.red)
            textField.textColor = Stylesheet.color(.red)
        } else {
            textField.dividerActiveColor = Stylesheet.color(.gray)
            textField.dividerNormalColor = Stylesheet.color(.gray)
            textField.textColor = Stylesheet.color(.lightBlack)
        }
    }
}
