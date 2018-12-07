//
//  DepositInfoViewController.swift
//  Lumenshine
//
//  Created by Soneso on 05/12/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material

class DepositInfoViewController: UIViewController {    
    @IBOutlet weak var xlmButton: UIButton!
    @IBOutlet weak var otherCurrencyButton: UIButton!
    var walletsList: [Wallet]!
    var baseViewController: UIViewController!
    
    private var depositXLMViewController: DepositXLMViewController!
    private var depositOtherCurrencyViewController: DepositOtherCurrencyViewController!
    
    @IBAction func xlmButtonAction(_ sender: UIButton) {
        if depositXLMViewController == nil {
            depositXLMViewController = DepositXLMViewController()
            depositXLMViewController.walletsList = walletsList
            depositXLMViewController.closeAction = { [weak self] in
                self?.dismiss(animated: true)
            }
            
            depositXLMViewController.copyButtonAction = { [weak self] (text) in
                UIPasteboard.general.string = text
                let alert = UIAlertController(title: nil, message: "Copied to clipboard", preferredStyle: .actionSheet)
                self?.present(alert, animated: true)
                let when = DispatchTime.now() + 0.75
                DispatchQueue.main.asyncAfter(deadline: when){
                    alert.dismiss(animated: true)
                }
            }
        }
        
        self.view.addSubview(depositXLMViewController.view)
        
        depositXLMViewController.view.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    @IBAction func otherCurrencyButtonAction(_ sender: UIButton) {
        if depositOtherCurrencyViewController == nil {
            depositOtherCurrencyViewController = DepositOtherCurrencyViewController()
            depositOtherCurrencyViewController.walletsList = walletsList
            
            depositOtherCurrencyViewController.payWithChangelly = { wallet in
                self.dismiss(animated: true, completion: {
                    self.setupPayWithChangellyWebView(forWallet: wallet)
                })
            }
        }
        
        self.view.addSubview(depositOtherCurrencyViewController.view)

        depositOtherCurrencyViewController.view.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    @IBAction func closeButtonAction(sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupNavigationItem()
    }
    
    private func setupView() {
        view.backgroundColor = Stylesheet.color(.veryLightGray)
        xlmButton.backgroundColor = Stylesheet.color(.blue)
        otherCurrencyButton.backgroundColor = Stylesheet.color(.blue)
    }
    
    private func setupNavigationItem() {
        navigationItem.titleLabel.text = "Deposit"
        navigationItem.titleLabel.textColor = Stylesheet.color(.blue)
        navigationItem.titleLabel.font = R.font.encodeSansSemiBold(size: 15)
        
        let backButton = Material.IconButton()
        backButton.image = Icon.close?.tint(with: Stylesheet.color(.gray))
        backButton.addTarget(self, action: #selector(closeButtonAction(sender:)), for: .touchUpInside)
        navigationItem.leftViews = [backButton]
    }
    
    private func getIFrame(height: CGFloat, topMargin: CGFloat, wallet: Wallet) -> String {
        var scale = "0.85"
        if UIDevice.current.screenType == .iPhone5 {
            scale = "0.60"
        }
        
        return "<iframe src=\"https://old.changelly.com/widget/v1?auth=email&from=BTC&to=XLM&merchant_id=dcaa3ae0e64f&address=\(wallet.publicKey)&amount=0.1&ref_id=dcaa3ae0e64f&color=00cf70\" class=\"changelly\" scrolling=\"no\" height=\"\(height)\" style=\"overflow-y: hidden; overflow-x: hidden; border: none; position:absolute; left:-128px; top:-\(topMargin)px; transform: scale(\(scale));\"></iframe>"
    }
    
    private func setupPayWithChangellyWebView(forWallet wallet: Wallet) {
        let viewHeight = self.view.frame.height
        let topMargin = ((viewHeight * 25) / 100) / 2
        let webViewController = WebViewController(title: "Pay with changelly", iFrame: getIFrame(height: viewHeight, topMargin: topMargin, wallet: wallet))
        let composeVC = ComposeNavigationController(rootViewController: webViewController)
        self.baseViewController.present(composeVC, animated: true)
    }
}
