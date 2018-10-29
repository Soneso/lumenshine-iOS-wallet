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
    fileprivate let attributedText: NSAttributedString?
    
    init(info: String, attributedText: NSAttributedString? = nil, title: String? = nil) {
        self.titleStr = title
        self.attributedText = attributedText
        self.textLabel.text = info
        super.init(nibName: nil, bundle: nil)
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
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

fileprivate extension InfoViewController {
    func prepareView() {
        view.backgroundColor = UIColor(red: 243/255.0, green: 243/255.0, blue: 243/255.0, alpha: 1.0)
        prepareTextLabel()
        if attributedText != nil {
            textLabel.attributedText = attributedText
        }
    }
    
    func prepareTextLabel() {
        textLabel.numberOfLines = 0
        textLabel.font = R.font.encodeSansRegular(size: 14)
        textLabel.textColor = Stylesheet.color(.lightBlack)
        
        view.addSubview(textLabel)
        textLabel.snp.makeConstraints { make in
            make.top.equalTo(20)
            make.left.equalTo(30)
            make.right.equalTo(-30)
            make.bottom.lessThanOrEqualToSuperview()
        }
    }
    
    func prepareNavigationItem() {
        
        navigationItem.titleLabel.text = titleStr
        navigationItem.titleLabel.textColor = Stylesheet.color(.blue)
        navigationItem.titleLabel.font = R.font.encodeSansSemiBold(size: 15)
        
        let backButton = Material.IconButton()
        backButton.image = Icon.close?.tint(with: Stylesheet.color(.gray))
        backButton.addTarget(self, action: #selector(closeAction(sender:)), for: .touchUpInside)
        navigationItem.leftViews = [backButton]
    }
}
