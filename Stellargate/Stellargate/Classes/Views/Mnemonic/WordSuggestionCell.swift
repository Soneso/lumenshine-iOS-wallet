//
//  WordSuggestionCell.swift
//  Stellargate
//
//  Created by Istvan Elekes on 3/28/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit

class WordSuggestionCell: UICollectionViewCell {
    
    fileprivate let titleLabel = UILabel()
    
    static let cellIdentifier = "WordSuggestionCell"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        titleLabel.textColor = Stylesheet.color(.white)
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isHighlighted: Bool {
        didSet {
            contentView.backgroundColor = isHighlighted ? Stylesheet.color(.lightGray) : nil
            titleLabel.textColor = isHighlighted ? Stylesheet.color(.darkGray): Stylesheet.color(.white)
        }
    }
    
    func setTitle(_ title: String?) {
        titleLabel.text = title
    }
}
