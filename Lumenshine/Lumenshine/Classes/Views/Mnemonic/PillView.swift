//
//  PillView.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 3/28/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit

class PillView: UIView {
    let viewHeight: CGFloat = 30.0
    let indexWidth: CGFloat = 13.0
    let indexPadding: CGFloat = 4.0
    let viewPadding: CGFloat = 10.0
    let verticalSpacing: CGFloat = 42.0
    let horizontalSpacing: CGFloat = 8.0
    
    init(index: String, title: String, origin: CGPoint) {
        super.init(frame: CGRect(origin: origin, size: CGSize(width: 0.0, height: viewHeight)))
        
        setupView(index: index, title: title)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView(index: String, title: String) {
        let indexLabel = UILabel(frame: CGRect(x: viewPadding, y: 0.0, width: indexWidth, height: viewHeight))
        indexLabel.text = index
        indexLabel.textColor = Stylesheet.color(.lightGray)
        indexLabel.font = UIFont.systemFont(ofSize: 10, weight: .medium)
        indexLabel.textAlignment = .left
        
        addSubview(indexLabel)
        
        let titleLabel = UILabel(frame: CGRect(x: (viewPadding + indexWidth + indexPadding), y: 0.0, width: 0, height: viewHeight))
        titleLabel.text = title
        titleLabel.textColor = Stylesheet.color(.darkGray)
        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        titleLabel.textAlignment = .left
        let size = titleLabel.text?.size(withAttributes: [.font: titleLabel.font]) ?? .zero
        titleLabel.frame.size.width = size.width
        
        addSubview(titleLabel)
        
        frame.size.width = size.width + (viewPadding * 2) + indexWidth + indexPadding
        backgroundColor = Stylesheet.color(.white)
        layer.borderColor = Stylesheet.color(.lightGray).cgColor
        layer.borderWidth = 1.0
        layer.cornerRadius = 16.0
    }
}

