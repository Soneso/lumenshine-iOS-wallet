//
//  HomeFoundedHeaderView.swift
//  Lumenshine
//
//  Created by Razvan Chelemen on 13/06/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material

class HomeFoundedHeaderView: UIView {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var foundAccountButton: UILabel!
    @IBOutlet weak var sendButton: IconButton!
    @IBOutlet weak var receiveButton: IconButton!
    @IBOutlet weak var moreButton: IconButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        setup()
    }
    
    private func setup() {
        titleLabel.text = R.string.localizable.homeScreenTitle()
        titleLabel.font = UIFont.boldSystemFont(ofSize: 40.0)
        titleLabel.textColor = Stylesheet.color(.white)
        
        sendButton.iconLabel.text = R.string.localizable.send()
        sendButton.iconImageView.image = UIImage(named: "send")?.tint(with: Stylesheet.color(.white))
        sendButton.iconLabel.textColor = Stylesheet.color(.white)
        receiveButton.iconLabel.text = R.string.localizable.receive()
        receiveButton.iconImageView.image = UIImage(named: "receive")?.tint(with: Stylesheet.color(.white))
        receiveButton.iconLabel.textColor = Stylesheet.color(.white)
        moreButton.iconLabel.text = R.string.localizable.more()
        moreButton.iconImageView.image = UIImage(named: "more")?.tint(with: Stylesheet.color(.white))
        moreButton.iconLabel.textColor = Stylesheet.color(.white)
    }
    
}
