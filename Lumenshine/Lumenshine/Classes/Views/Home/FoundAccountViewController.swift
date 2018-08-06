//
//  FoundAccountViewController.swift
//  Lumenshine
//
//  Created by Razvan Chelemen on 06/07/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import TTTAttributedLabel

class FoundAccountViewController: UIViewController {

    @IBOutlet weak var publicKeyButton: UIButton!
    @IBOutlet weak var descriptionLabel: TTTAttributedLabel!
    
    var wallet: Wallet?
    
    var walletService: WalletsService {
        get {
            return Services.shared.walletService
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        publicKeyButton.titleLabel?.numberOfLines = 0
        
        if let wallet = wallet {
            publicKeyButton.setTitle(wallet.publicKey, for: .normal)
        } else {
            loadWallet()
        }
        setDescription()
    }

    @IBAction func didTapPublicKey(_ sender: Any) {
        
    }
    
    @IBAction func didTapClose(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    private func loadWallet() {
        walletService.getWallets { (result) -> (Void) in
            switch result {
            case .success(let data):
                if data.count == 1 {
                    let wallet = data[0]
                    self.publicKeyButton.setTitle(wallet.publicKey, for: .normal)
                } else {
                    print("Invalid wallets")
                }
            case .failure(let error):
                print("Failed to get wallets: \(error.localizedDescription)")
            }
        }
    }
    
    private func setDescription() {
        let linkAttributes = [ NSAttributedStringKey.foregroundColor: UIColor.blue, NSAttributedStringKey.underlineStyle: NSUnderlineStyle.styleSingle.rawValue ] as [NSAttributedStringKey : Any]
        
        
        let text = "In order to prevent people from making a huge number of unnecessary accounts, each account in the stellar blockchain must have a minimum balance of 1 XLM (Stellar Lumen). Please send your Stellar Lumens (XLM) to the above displayed Account ID / Public key. At least 1 XLM is needed to found your wallet in the stellar blockchain. We recommend a minimum of 2 XLM.\n\nQ: I don't have Stellar Lumens. Where can I get Stellar Lumens (XLM)?\n\nA: You can pay an exchange that sells lumens in order to found your wallet. CoinMarketCap maintains a list of exchanges that sell Stellar Lumens (XLM). After purchasing the lumens withdraw them from the exchange to your wallet by sending them to the above displayed Account ID / Public key in order to found your wallet."
        
        descriptionLabel.text = text
        descriptionLabel.activeLinkAttributes = linkAttributes
        descriptionLabel.linkAttributes = linkAttributes
        
        if let range = text.range(of: "CoinMarketCap") {
            let objcRange = NSMakeRange(range.lowerBound.encodedOffset, range.upperBound.encodedOffset - range.lowerBound.encodedOffset)
            descriptionLabel.addLink(to: URL(string: "https://coinmarketcap.com/"), with: objcRange)
        }
    }
    
}
