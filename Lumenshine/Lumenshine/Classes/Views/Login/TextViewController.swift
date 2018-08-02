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
    fileprivate let infoLabel = UILabel()
    fileprivate let titleText: String
    
    init(title: String, text: String) {
        self.titleText = title
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
        prepareInfoLabel()
        prepareTextLabel()
    }
    
    func prepareInfoLabel() {
        let infoImage = UIImageView()
        infoImage.image = R.image.question()
        infoImage.shapePreset = .circle
        infoImage.backgroundColor = Stylesheet.color(.white)
        
        view.addSubview(infoImage)
        infoImage.snp.makeConstraints { make in
            make.top.equalTo(20)
            make.right.equalTo(view.snp.centerX)
        }
        
        infoLabel.text = R.string.localizable.info()
        infoLabel.font = Stylesheet.font(.body)
        infoLabel.textAlignment = .left
        infoLabel.textColor = Stylesheet.color(.black)
        
        view.addSubview(infoLabel)
        infoLabel.snp.makeConstraints { make in
            make.centerY.equalTo(infoImage)
            make.left.equalTo(infoImage.snp.right).offset(5)
        }
    }
    
    func prepareTextLabel() {
        textLabel.numberOfLines = 0
        
        view.addSubview(textLabel)
        textLabel.snp.makeConstraints { make in
            make.top.equalTo(infoLabel.snp.bottom).offset(30)
            make.left.equalTo(30)
            make.right.equalTo(-30)
            make.bottom.lessThanOrEqualToSuperview()
        }
    }
    
    func prepareNavigationItem() {
        navigationItem.titleLabel.text = titleText
        navigationItem.titleLabel.textColor = Stylesheet.color(.white)
        
        let backButton = Material.IconButton()
        backButton.image = Icon.close?.tint(with: Stylesheet.color(.white))
        backButton.addTarget(self, action: #selector(closeAction(sender:)), for: .touchUpInside)
        navigationItem.leftViews = [backButton]
    }
    

}
