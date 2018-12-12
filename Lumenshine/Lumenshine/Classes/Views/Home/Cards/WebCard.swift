//
//  WebCard.swift
//  Lumenshine
//
//  Created by Soneso GmbH on 12/12/2018.
//  Munich, Germany
//  web: https://soneso.com
//  email: hi@soneso.com
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material
import SnapKit

protocol WebCardProtocol {
    func setImage(from URL: URL?)
    func setTitle(_ text: String?)
    func setDetail(_ detail: String?)
}

class WebCard: CardView {
    
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
            setImage(from: viewModel?.imageURL)
            setTitle(viewModel?.title)
            setDetail(viewModel?.detail)
        }
    }
}

extension WebCard: WebCardProtocol {
    func setImage(from URL: URL?) {
        guard let url = URL else {return}
        UIImage.contentsOfURL(url: url) { (image, error) in
            if error == nil {
                self.imageView.image = image
                self.setNeedsDisplay()
            }
        }
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
        prepareImage()
        prepareTitle()
        prepareDetail()
    }
    
    func prepareImage() {
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.lessThanOrEqualTo(300)
        }
    }
    
    func prepareTitle() {
        titleLabel.textColor = Stylesheet.color(.black)
        titleLabel.font = Stylesheet.font(.body)
        titleLabel.textAlignment = .center
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.numberOfLines = 0
        
        contentView.addSubview(titleLabel)
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
        
        contentView.addSubview(detailLabel)
        detailLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(5)
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.bottom.equalTo(bottomBar.snp.top).offset(-5)
        }
    }
}
