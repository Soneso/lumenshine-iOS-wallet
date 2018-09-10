//
//  FundTestAccountViewController.swift
//  Lumenshine
//
//  Created by Soneso on 14/08/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation
import UIKit

public enum FundButtonTitles: String {
    case funding = "Funding"
    case success = "Funded successfully!"
    case failure = "Funding failed!"
}

public class FundTestAccountViewController: UIViewController {
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var publicKeyButton: UIButton!
    @IBOutlet weak var fundButton: UIButton!
    
    private var wallet: Wallet!
    private let userManager = UserManager()
    
    @IBAction func publicKeyButtonAction(_ sender: UIButton) {
        if let key = publicKeyButton.titleLabel?.text {
            UIPasteboard.general.string = key
        }
    }
    
    @IBAction func closeButtonAction(_ sender: UIButton) {
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
}
