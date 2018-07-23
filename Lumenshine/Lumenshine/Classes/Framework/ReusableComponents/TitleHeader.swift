//
//  TitleHeader.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 7/16/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit

protocol TitleHeaderProtocol {
    func setTitle(_ title: String?)
    func setDetail(_ detail: String?)
    func setHeader(_ text: String?)
}

class TitleHeader: UIView {
    
    fileprivate let titleLabel = UILabel()
    fileprivate let detailLabel = UILabel()
    fileprivate let headerLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        
        backgroundColor = Stylesheet.color(.cyan)
        
        titleLabel.font = UIFont.systemFont(ofSize: 25.0)
        titleLabel.textColor = Stylesheet.color(.orange)
        titleLabel.textAlignment = .center
        titleLabel.sizeToFit()
        
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
        }
        
        detailLabel.font = UIFont.systemFont(ofSize: 16.0)
        detailLabel.textColor = Stylesheet.color(.white)
        detailLabel.textAlignment = .center
        detailLabel.numberOfLines = 0
        detailLabel.sizeToFit()
        
        addSubview(detailLabel)
        detailLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom)
            make.left.right.equalToSuperview()
        }
        
        headerLabel.font = UIFont.systemFont(ofSize: 26.0)
        headerLabel.textColor = Stylesheet.color(.yellow)
        headerLabel.textAlignment = .center
        headerLabel.sizeToFit()
        
        addSubview(headerLabel)
        headerLabel.snp.makeConstraints { make in
            make.top.equalTo(detailLabel.snp.bottom).offset(10)
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.bottom.equalTo(-10)
        }
    }
}

extension TitleHeader: TitleHeaderProtocol {
    func setTitle(_ title: String?) {
        titleLabel.text = title
    }
    
    func setDetail(_ detail: String?) {
        detailLabel.text = detail
    }
    
    func setHeader(_ text: String?) {
        headerLabel.text = text
    }
}

