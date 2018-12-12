//
//  WebViewController.swift
//  Lumenshine
//
//  Created by Soneso GmbH on 12/12/2018.
//  Munich, Germany
//  web: https://soneso.com
//  email: hi@soneso.com
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import WebKit
import Material

class WebViewController: UIViewController {
    fileprivate let stitle: String
    fileprivate let url: String?
    fileprivate let iFrame: String?
    
    private var webView: WKWebView!
    
    init(title: String, url: String) {
        self.stitle = title
        self.url = url
        self.iFrame = nil
        super.init(nibName: nil, bundle: nil)
    }
    
    init(title: String, iFrame: String) {
        self.stitle = title
        self.url = nil
        self.iFrame = iFrame
        super.init(nibName: nil, bundle:nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareNavigationItems()
        
        navigationItem.titleLabel.text = stitle
        
        if let iFrame = iFrame {
            let jscript = "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width, height=device-height'); document.getElementsByTagName('head')[0].appendChild(meta);"
            let userScript = WKUserScript(source: jscript, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
            let wkUController = WKUserContentController()
            wkUController.addUserScript(userScript)
            let wkWebConfig = WKWebViewConfiguration()
            wkWebConfig.userContentController = wkUController
            webView = WKWebView(frame: view.bounds, configuration: wkWebConfig)
            view = webView
            
            webView.loadHTMLString(iFrame, baseURL: nil)
            return
        }

        if let inputUrl = url, let url = URL(string: inputUrl) {
            webView = WKWebView()
            view = webView
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
