//
//  LeftCaptionTextField.swift
//  Lumenshine
//
//  Created by Soneso on 08/10/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit

class LeftCaptionTextField: InputTextField {
    private let horizontalSpace = CGFloat(16)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    private func setup() {
        clearButtonMode = .always
        if let caption = placeholder, let font = font {
            let label = UILabel()
            label.text = caption
            label.font = font
            label.textColor = textColor
            let view = UIView(frame: CGRect(x: 0, y: 0, width: caption.getSize(usingFont: font).width + horizontalSpace * 2, height: self.bounds.height))
            view.addSubview(label)
            label.snp.makeConstraints { (make) in
                make.left.equalTo(horizontalSpace)
                make.right.equalTo(horizontalSpace)
                make.top.equalToSuperview()
                make.bottom.equalToSuperview()
            }
            
            leftView = view
            placeholder = ""
        }
    }
}
