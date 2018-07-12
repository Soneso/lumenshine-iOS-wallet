//
//  TextViewController.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 7/12/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material

class TextViewController: UIViewController {
    
    // MARK: - Properties
    
    // MARK: - UI properties
    fileprivate let textLabel = UILabel()
    
    init(text: String) {
        super.init(nibName: nil, bundle: nil)
        textLabel.text = text
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareView()
        prepareNavigationItem()
    }
    
    @objc
    func closeAction(sender: UIButton) {
        dismiss(animated: true)
    }
}

fileprivate extension TextViewController {
    func prepareView() {
        textLabel.numberOfLines = 0
        
        view.addSubview(textLabel)
        textLabel.snp.makeConstraints { make in
            make.top.left.equalTo(30)
            make.right.equalTo(-30)
            make.bottom.lessThanOrEqualToSuperview()
        }
    }
    
    func prepareNavigationItem() {
        navigationItem.titleLabel.text = R.string.localizable.password_hint_title()
        navigationItem.titleLabel.textColor = Stylesheet.color(.white)
        
        let backButton = Material.IconButton()
        backButton.image = Icon.close?.tint(with: Stylesheet.color(.white))
        backButton.addTarget(self, action: #selector(closeAction(sender:)), for: .touchUpInside)
        navigationItem.leftViews = [backButton]
    }
}
