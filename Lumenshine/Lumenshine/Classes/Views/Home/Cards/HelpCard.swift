//
//  InternalCard.swift
//  Lumenshine
//
//  Created by Soneso GmbH on 12/12/2018.
//  Munich, Germany
//  web: https://soneso.com
//  email: hi@soneso.com
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import SnapKit

protocol HelpCardProtocol {
    func setImage(from URL: URL?)
    func setImage(_ image: UIImage?)
    func setTitle(_ text: String?)
    func setDetail(_ detail: String?)
}

class HelpCard: CardView {
    
    fileprivate let imageView = UIImageView()
    fileprivate let titleLabel = UILabel()
    fileprivate let detailLabel = UILabel()
    fileprivate let horizontalSpacing = 15.0
    
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

extension HelpCard: HelpCardProtocol {
    func setImage(from URL: URL?) {
        guard let url = URL else {return}
        UIImage.contentsOfURL(url: url) { (image, error) in
            if error == nil {
                self.imageView.image = image
            }
        }
    }
    
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

fileprivate extension HelpCard {
    func prepare() {
        prepareImage()
        prepareTitle()
        prepareDetail()
    }
    
    func prepareImage() {
        imageView.contentMode = .scaleAspectFit
        
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.top.equalTo(2*horizontalSpacing)
            make.left.equalTo(horizontalSpacing)
            make.right.equalTo(-horizontalSpacing)
            make.height.lessThanOrEqualTo(300)
        }
    }
    
    func prepareTitle() {
        titleLabel.textColor = Stylesheet.color(.lightBlack)
        titleLabel.font = R.font.encodeSansSemiBold(size: 16)
        titleLabel.textAlignment = .center
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.numberOfLines = 0
        
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(imageView.snp.bottom).offset(20)
            make.left.equalTo(horizontalSpacing)
            make.right.equalTo(-horizontalSpacing)
        }
    }
    
    func prepareDetail() {
        detailLabel.textColor = Stylesheet.color(.lightBlack)
        detailLabel.font = R.font.encodeSansRegular(size: 13)
        detailLabel.textAlignment = .left
        detailLabel.adjustsFontSizeToFitWidth = true
        detailLabel.numberOfLines = 0
        
        contentView.addSubview(detailLabel)
        detailLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.left.equalTo(horizontalSpacing)
            make.right.equalTo(-horizontalSpacing)
            make.bottom.equalTo(bottomBar.snp.top).offset(-15)
        }
    }
}
