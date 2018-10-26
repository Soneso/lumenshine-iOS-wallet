//
//  MultilineInputTableViewCell.swift
//  Lumenshine
//
//  Created by Elekes Istvan on 24/10/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material

class MultilineInputTableViewCell: InputTableViewCell {
    
    // MARK: - Parameters & Constants
    
    override class var CellIdentifier: String {
        return "MultilineInputDataCell"
    }
    
    // MARK: - Properties
    
    fileprivate let horizontalSpacing: CGFloat = 15.0
    fileprivate let textView = UITextView()
    fileprivate let separator = UIView()
    fileprivate var placeholder: String?
    
    var cellSizeChangedCallback: ((_ size:CGFloat) -> ())?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cellSizeChangedCallback = nil
    }
    
    override func commonInit() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = Stylesheet.color(.white)
        
        textView.autocapitalizationType = .none
        textView.autocorrectionType = .no
        textView.delegate = self
        textView.isScrollEnabled = false
        textView.font = R.font.encodeSansSemiBold(size: 14)
        textView.textColor = Stylesheet.color(.lightBlack)
        textView.tintColor = Stylesheet.color(.lightBlack)
        textView.textContainerInset = UIEdgeInsets(top: 0, left: -5, bottom: 2, right: 0)
        
        contentView.addSubview(textView)
        textView.snp.makeConstraints { (make) in
            make.top.equalTo(horizontalSpacing)
            make.left.equalTo(horizontalSpacing)
            make.right.equalTo(-horizontalSpacing)
            make.bottom.equalTo(-horizontalSpacing)
        }
        
        separator.borderColor = Stylesheet.color(.lightGray)
        separator.borderWidthPreset = .border1
        
        contentView.addSubview(separator)
        separator.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.left.equalTo(horizontalSpacing)
            make.right.equalTo(-horizontalSpacing)
            make.top.equalTo(textView.snp.bottom)
        }
    }
    
    override func setPlaceholder(_ placeholder: String?) {
        self.placeholder = placeholder
        if textView.text.isEmpty {
            textView.text = placeholder
        }
    }
    
    override func setText(_ text: String?) {
        textView.text = text
        cellSizeChangedCallback?(textView.newHeight(withBaseHeight: 25))
    }
}

extension MultilineInputTableViewCell: UITextViewDelegate {
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        guard let callback = shouldBeginEditingCallback else {
            return true
        }
        return callback()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        textEditingCallback?(textView.text)
        cellSizeChangedCallback?(textView.newHeight(withBaseHeight: 25))
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == placeholder {
            textView.text = ""
        }
        
        separator.borderColor = Stylesheet.color(.gray)
        separator.borderWidthPreset = .border3
        separator.snp.updateConstraints { make in
            make.height.equalTo(2)
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = placeholder
        }
        
        separator.borderColor = Stylesheet.color(.lightGray)
        separator.borderWidthPreset = .border1
        separator.snp.updateConstraints { make in
            make.height.equalTo(1)
        }
    }
}

