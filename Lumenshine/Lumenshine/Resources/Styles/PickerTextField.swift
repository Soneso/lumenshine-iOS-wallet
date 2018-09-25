//
//  PickerTextField.swift
//  Lumenshine
//
//  Created by Soneso on 20/09/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit

class PickerTextField: InputTextField, UITextFieldDelegate {
    override func awakeFromNib() {
        super.awakeFromNib()
        let openPicker = UITapGestureRecognizer(target: self, action: #selector(self.openPicker))
        addGestureRecognizer(openPicker)
        delegate = self
        setup()
    }
    
    @objc func openPicker(_ textField: UITextField) {
        becomeFirstResponder()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return false
    }
    
    private func setup() {
        rightView = UIView(frame: CGRect(x: frame.width - 16, y: 0, width: 26, height: frame.height))
        
        let image = UIImageView(image: R.image.arrowLeft()?.crop(toWidth: 10, toHeight: 16))
        
        rightView?.addSubview(image)
        image.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        
        rightViewMode = UITextFieldViewMode.always
    }
}
