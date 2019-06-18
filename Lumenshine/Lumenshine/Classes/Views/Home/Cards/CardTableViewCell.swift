//
//  CardTableViewCell.swift
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

class CardTableViewCell: UITableViewCell {
    
    fileprivate let inset = 15.0
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var card: CardView? {
        willSet {
            contentView.subviews.forEach {
                $0.removeFromSuperview()
            }
        }
        didSet {
            guard let v = card else {
                return
            }

            contentView.addSubview(v)
            v.snp.makeConstraints { (make) in
                make.top.equalTo(inset)
                make.left.equalTo(inset)
                make.right.equalTo(-inset)
                make.bottom.equalTo(-inset)
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        card = nil
    }
}
