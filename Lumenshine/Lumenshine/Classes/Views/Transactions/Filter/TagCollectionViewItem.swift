//
//  TagCollectionViewItem.swift
//  Lumenshine
//
//  Created by Elekes Istvan on 22/11/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit

protocol TagCollectionViewItemProtocol {
    func setTitle(_ text: String?)
    func setColor(_ color: UIColor)
}

class TagCollectionViewItem: UICollectionViewCell {
    
    fileprivate let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        prepare()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        setNeedsLayout()
        layoutIfNeeded()
        layoutAttributes.size = contentView.systemLayoutSizeFitting(layoutAttributes.size)
        return layoutAttributes
    }
}

extension TagCollectionViewItem: TagCollectionViewItemProtocol {
    func setTitle(_ text: String?) {
        titleLabel.text = text
    }
    
    func setColor(_ color: UIColor) {
        contentView.backgroundColor = color
    }
}

fileprivate extension TagCollectionViewItem {
    func prepare() {
        contentView.backgroundColor = Stylesheet.color(.blue)
        contentView.clipsToBounds = true
        contentView.cornerRadiusPreset = .cornerRadius2
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.textColor = Stylesheet.color(.white)
        titleLabel.font = R.font.encodeSansRegular(size: 12)
        titleLabel.textAlignment = .center
        titleLabel.adjustsFontSizeToFitWidth = true
        
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalTo(2)
            make.right.equalTo(-2)
            make.bottom.equalToSuperview()
        }
    }
}

