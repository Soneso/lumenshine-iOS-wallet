//
//  DepositXLMViewController.swift
//  Lumenshine
//
//  Created by Soneso on 05/12/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit

class DepositXLMViewController: UIViewController {
    var walletsList: [Wallet]!
    var closeAction: (() -> ())?
    var copyButtonAction: ((String) -> ())?
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var publicKeyLabel: UILabel!
    @IBOutlet weak var qrImageView: UIImageView!
    @IBOutlet weak var walletsViewContainer: UIView!
    
    private var walletsView: WalletsView!
    private var wallet: Wallet!
    
    @IBAction func backButtonAction(_ sender: UIButton) {
        view.removeFromSuperview()
    }
    
    @IBAction func doneButtonAction(_ sender: UIButton) {
        closeAction?()
    }

    @IBAction func didTapCopyButton(_ sender: UIButton) {
        if let key = publicKeyLabel.text {
            copyButtonAction?(key)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        wallet = walletsList?.first
        setupWalletsView()
        setupView()
        setupPublicKey()
        setupQRCode()
    }
    
    private func setupView() {
        view.backgroundColor = Stylesheet.color(.veryLightGray)
        backButton.backgroundColor = Stylesheet.color(.blue)
        doneButton.backgroundColor = Stylesheet.color(.green)
    }
    
    private func setupPublicKey() {
        publicKeyLabel.text = wallet.publicKey
    }
    
    private func setupQRCode() {
        if let image = QRCoder.qrCodeImage(qrValueString: wallet.publicKey, size:10) {
            self.qrImageView.image = image
        }
    }
    
    private func setupWalletsView() {
        if walletsList.count == 1 {
            return
        }
        
        walletsView = Bundle.main.loadNibNamed("WalletsPickerView", owner: self, options: nil)![0] as? WalletsView
        walletsView.walletsList = walletsList
        walletsViewContainer.addSubview(walletsView)
        
        walletsView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        walletsView.walletChanged = { (wallet) in
            self.wallet = wallet
            self.setupPublicKey()
            self.setupQRCode()
        }
    }
}
