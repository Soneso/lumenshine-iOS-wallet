//
//  DepositOtherCurrencyViewController.swift
//  Lumenshine
//
//  Created by Soneso on 05/12/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit

class DepositOtherCurrencyViewController: UIViewController {
    var walletsList: [Wallet]!
    var payWithChangelly: ((Wallet) -> ())?
    
    private var wallet: Wallet!
    private var walletsView: WalletsView!
    
    @IBOutlet weak var walletsViewContainer: UIView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var payWithChangellyButton: UIButton!

    @IBAction func backButtonAction(_ sender: UIButton) {
        view.removeFromSuperview()
    }
    
    @IBAction func payWithChangellyButtonAction(_ sender: UIButton) {
        payWithChangelly?(wallet)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        wallet = walletsList.first
        setupWalletsView()
    }
    
    private func setupView() {
        view.backgroundColor = Stylesheet.color(.veryLightGray)
        backButton.backgroundColor = Stylesheet.color(.blue)
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
        }
    }
}
