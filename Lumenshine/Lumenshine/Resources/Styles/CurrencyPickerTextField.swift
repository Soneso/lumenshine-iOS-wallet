//
//  CurrencyPickerTextField.swift
//  Lumenshine
//
//  Created by Soneso on 20/09/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit

class CurrencyPickerTextField: PickerTextField {
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    private func setup() {
        let currencyLabel = UILabel()
        currencyLabel.text = "Currency"
        currencyLabel.font = R.font.encodeSansSemiBold(size: 12)
        currencyLabel.textColor = Stylesheet.color(.lightBlack)
        
        leftView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: frame.height))
        leftViewMode = UITextFieldViewMode.always
        leftView?.addSubview(currencyLabel)
        currencyLabel.snp.makeConstraints { (make) in
            make.left.equalTo(16)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.right.equalToSuperview()
        }
    }
}
