//
//  WebCard.swift
//  Stellargate
//
//  Created by Istvan Elekes on 3/9/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material
import SnapKit

protocol WebCardProtocol {
    func setImage(_ image: UIImage?)
    func setTitle(_ text: String?)
    func setDetail(_ detail: String?)
}

class WebCard: Card {
    
    fileprivate let imageView = UIImageView()
    fileprivate let titleLabel = UILabel()
    fileprivate let detailLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        prepare()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var viewModel: CardViewModelType? {
        didSet {
            setImage(viewModel?.image)
            setTitle(viewModel?.title)
            setDetail(viewModel?.detail)
        }
    }
}

extension WebCard: WebCardProtocol {
    func setImage(_ image: UIImage?) {
        imageView.image = image
    }
    
    func setTitle(_ text: String?) {
        titleLabel.text = text
    }
    
    func setDetail(_ detail: String?) {
        detailLabel.text = detail
    }
}

fileprivate extension WebCard {
    func prepare() {
        
        cornerRadiusPreset = .cornerRadius3
        depthPreset = .depth3
        
        backgroundColor = Stylesheet.color(.white)
        
        prepareImage()
        prepareTitle()
        prepareDetail()
    }
    
    func prepareImage() {
        addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
        }
    }
    
    func prepareTitle() {
        titleLabel.textColor = Stylesheet.color(.black)
        titleLabel.font = Stylesheet.font(.body)
        titleLabel.textAlignment = .center
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.numberOfLines = 0
        
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(imageView.snp.bottom).offset(10)
            make.left.right.equalToSuperview()
        }
    }
    
    func prepareDetail() {
        detailLabel.textColor = Stylesheet.color(.black)
        detailLabel.font = Stylesheet.font(.callout)
        detailLabel.textAlignment = .left
        detailLabel.adjustsFontSizeToFitWidth = true
        detailLabel.numberOfLines = 0
        
        addSubview(detailLabel)
        detailLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(5)
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.bottom.equalTo(bottomBar.snp.top).offset(-5)
        }
    }
}


