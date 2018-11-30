//
//  LSTextField.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 9/14/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material

class LSTextField: TextField {
    
    init() {
        super.init(frame: .zero)
        placeholderAnimation = .hidden
        placeholderActiveColor = Stylesheet.color(.lightBlack)
        placeholderNormalColor = Stylesheet.color(.lightBlack)
        font = R.font.encodeSansSemiBold(size: 14)
        textColor = Stylesheet.color(.lightBlack)
        detailColor = Stylesheet.color(.red)
        detailLabel.font = R.font.encodeSansRegular(size: 13)
        detailLabel.adjustsFontSizeToFitWidth = true
        detailVerticalOffset = 0
        dividerActiveColor = Stylesheet.color(.gray)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func pasteText(_ text: String) {
        self.text = text
        _ = becomeFirstResponder()
        shake(for: 0.5)
        detail = nil
    }
    
    func setInputViewOptions(options: [String], selectedIndex: Int? = nil, handler: @escaping (_ newIndex: Int) -> (Void)) {
        let enumPicker = EnumPicker()
        enumPicker.setValues(options, currentSelection: selectedIndex) { (newIndex) in
            if newIndex < options.count {
                self.text = options[newIndex]
                handler(newIndex)
            }
        }
        self.text = options[selectedIndex ?? 0]
        self.inputView = enumPicker
    }
    
}
