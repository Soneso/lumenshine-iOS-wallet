//
//  InfoViewController.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 7/12/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material

class InfoViewController: UIViewController {
    
    // MARK: - Properties
    
    // MARK: - UI properties
    fileprivate let textLabel = UILabel()
    fileprivate let titleStr: String?
    
    init(info: String, attributedText: NSAttributedString? = nil, title: String? = nil) {
        self.titleStr = title
        super.init(nibName: nil, bundle: nil)
        if attributedText != nil {
            textLabel.attributedText = attributedText
        } else {
            textLabel.text = info
        }
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

fileprivate extension InfoViewController {
    func prepareView() {
        prepareTextLabel()
    }
    
    func prepareTextLabel() {
        textLabel.numberOfLines = 0
        
        view.addSubview(textLabel)
        textLabel.snp.makeConstraints { make in
            make.top.equalTo(20)
            make.left.equalTo(30)
            make.right.equalTo(-30)
            make.bottom.lessThanOrEqualToSuperview()
        }
    }
    
    func prepareNavigationItem() {
        let color = Stylesheet.color(.white)
        if let title = titleStr {
            navigationItem.titleLabel.text = title
            navigationItem.titleLabel.textColor = color
        } else {
            let button = Button(image: R.image.question()?.tint(with: color))
            button.isEnabled = false
            button.title = R.string.localizable.info()
            button.titleLabel?.font = Stylesheet.font(.body)
            button.titleColor = color
            button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
            navigationItem.centerViews = [button]
        }
        
        let backButton = Material.IconButton()
        backButton.image = Icon.close?.tint(with: Stylesheet.color(.white))
        backButton.addTarget(self, action: #selector(closeAction(sender:)), for: .touchUpInside)
        navigationItem.leftViews = [backButton]
    }
    

}
