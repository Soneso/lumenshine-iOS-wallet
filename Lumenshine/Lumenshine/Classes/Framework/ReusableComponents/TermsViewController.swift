//
//  TermsViewController.swift
//  Lumenshine
//
//  Created by Soneso on 17.11.18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import WebKit
import Material

class TermsViewController: UIViewController {
    
    fileprivate let webView = WKWebView()
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view = webView
        prepareNavigationItems()
        
        let terms = UIBarButtonItem(title: R.string.localizable.terms(), style: UIBarButtonItemStyle.plain, target: self, action: #selector(termsTapped))
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let privacy = UIBarButtonItem(title: R.string.localizable.privacy(), style: UIBarButtonItemStyle.plain, target: self, action: #selector(privacyTapped))
        let guidelines = UIBarButtonItem(title: R.string.localizable.guidelines(), style: UIBarButtonItemStyle.plain, target: self, action: #selector(guidelinesTapped))
        toolbarItems = [terms, spacer, privacy, spacer, guidelines]
        
        termsTapped()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setToolbarHidden(true, animated: false)
        super.viewWillDisappear(animated)
    }
    
    @objc
    func termsTapped() {
        navigationItem.titleLabel.text = R.string.localizable.terms_of_service()
        if let url = URL(string: Services.shared.termsUrl) {
            webView.load(URLRequest(url: url))
        }
    }
    
    @objc
    func privacyTapped() {
        navigationItem.titleLabel.text = R.string.localizable.privacy_policy()
        if let url = URL(string: Services.shared.privacyUrl) {
            webView.load(URLRequest(url: url))
        }
    }
    
    @objc
    func guidelinesTapped() {
        navigationItem.titleLabel.text = R.string.localizable.wallet_guidelines()
        if let url = URL(string: Services.shared.guidesUrl) {
            webView.load(URLRequest(url: url))
        }
    }
    
    @objc
    func closeAction(sender: UIButton) {
        dismiss(animated: true)
    }
    
    @objc
    func moreAction(sender: UIButton) {
        if let isHidden = navigationController?.toolbar.isHidden {
             navigationController?.setToolbarHidden(!isHidden, animated: true)
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func prepareNavigationItems() {
        
        navigationItem.titleLabel.textColor = Stylesheet.color(.blue)
        navigationItem.titleLabel.font = R.font.encodeSansSemiBold(size: 15)
        
        let backButton = Material.IconButton()
        backButton.image = Icon.close?.tint(with: Stylesheet.color(.gray))
        backButton.addTarget(self, action: #selector(closeAction(sender:)), for: .touchUpInside)
        navigationItem.leftViews = [backButton]
        
        let moreButton = Material.IconButton()
        moreButton.image = Icon.moreVertical?.tint(with: Stylesheet.color(.gray))
        moreButton.addTarget(self, action: #selector(moreAction(sender:)), for: .touchUpInside)
        navigationItem.rightViews = [moreButton]
    }
}
