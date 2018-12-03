//
//  WebViewController.swift
//  Lumenshine
//
//  Created by Soneso on 03.12.18.
//  Copyright © 2018 Soneso. All rights reserved.
//


import UIKit
import WebKit
import Material

class WebViewController: UIViewController {
    
    fileprivate let webView = WKWebView()
    fileprivate let stitle: String
    fileprivate let url: String
    
    init(title: String, url: String) {
        self.stitle = title
        self.url = url
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
        
        navigationItem.titleLabel.text = stitle
        if let url = URL(string: url) {
            webView.load(URLRequest(url: url))
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setToolbarHidden(true, animated: false)
        super.viewWillDisappear(animated)
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
    
    func prepareNavigationItems() {
        
        navigationItem.titleLabel.textColor = Stylesheet.color(.blue)
        navigationItem.titleLabel.font = R.font.encodeSansSemiBold(size: 15)
        
        let backButton = Material.IconButton()
        backButton.image = Icon.close?.tint(with: Stylesheet.color(.gray))
        backButton.addTarget(self, action: #selector(closeAction(sender:)), for: .touchUpInside)
        navigationItem.leftViews = [backButton]
        
    }
}
