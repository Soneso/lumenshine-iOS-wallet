//
//  FundButtonTitles.swift
//  Lumenshine
//
//  Created by Soneso on 14/08/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material

public enum FundButtonTitles: String {
    case funding = "Funding"
    case success = "Funded successfully!"
    case failure = "Funding failed!"
}

public class FundTestNetWalletViewController: UIViewController {
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var publicKeyButton: UIButton!
    @IBOutlet weak var fundButton: UIButton!
    
    private var wallet: Wallet!
    private let userManager = UserManager()
    
    @IBAction func publicKeyButtonAction(_ sender: UIButton) {
        if let key = publicKeyButton.titleLabel?.text {
            UIPasteboard.general.string = key
            let alert = UIAlertController(title: nil, message: "Copied to clipboard", preferredStyle: .actionSheet)
            self.present(alert, animated: true)
            let when = DispatchTime.now() + 1
            DispatchQueue.main.asyncAfter(deadline: when){
                alert.dismiss(animated: true)
            }
        }
    }
    
    @IBAction func closeButtonAction(sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @IBAction func fundTestButtonAction(_ sender: UIButton) {
       fundTestAccount()
    }
    
    public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, forWallet wallet: Wallet) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.wallet = wallet
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        prepareNavigationItem()
        setContent()
        publicKeyButton.titleLabel?.numberOfLines = 0
        publicKeyButton.setTitle(wallet.publicKey, for: UIControlState.normal)
    }
    
    private func setFundButtonTitle(titleEnum: FundButtonTitles) {
        fundButton.setTitle(titleEnum.rawValue, for: UIControlState.normal)
        fundButton.isEnabled = false
    }
    
    private func setContent() {
        contentLabel.text = "This client operates on the test net. Do not send real Stellar Lumens from the main/public net. To fund your wallet for testing purposes we can kindly ask Friendbot to send you some test lumens. Please press the button below to receive the test net lumens from Friendbot."
    }
    
    private func fundTestAccount() {
        setFundButtonTitle(titleEnum: FundButtonTitles.funding)
        userManager.createTestAccount(withAccountID: wallet.publicKey) { (response) -> (Void) in
            switch response {
            case .success(_):
                print("Success!")
                self.setFundButtonTitle(titleEnum: .success)
            case .failure(error: let error):
                print("Failure, error: \(error.localizedDescription)")
                self.setFundButtonTitle(titleEnum: .failure)
            }
            
            self.dismiss(animated: true)
        }
    }
    
    private func prepareNavigationItem() {
        
        navigationItem.titleLabel.text = R.string.localizable.fund_wallet_test()
        navigationItem.titleLabel.textColor = Stylesheet.color(.blue)
        navigationItem.titleLabel.font = R.font.encodeSansSemiBold(size: 15)
        
        let backButton = Material.IconButton()
        backButton.image = Icon.close?.tint(with: Stylesheet.color(.gray))
        backButton.addTarget(self, action: #selector(closeButtonAction(sender:)), for: .touchUpInside)
        navigationItem.leftViews = [backButton]
    }
}
