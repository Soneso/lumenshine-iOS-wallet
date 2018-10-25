//
//  AddWalletViewController.swift
//  Lumenshine
//
//  Created by Soneso on 25/10/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material

class AddWalletViewController: UIViewController {
    @IBOutlet weak var walletNameTextField: UITextField!
    
    @IBOutlet weak var publicKeyValueLabel: UILabel!
    
    @IBOutlet weak var showOnHomescreenSwitch: UISwitch!
    
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var walletNameValidationView: UIView!
    
    var walletCount: Int!
    
    private var walletService: WalletsService {
        get {
            return Services.shared.walletService
        }
    }
    
    private var isWalletNameValid: Bool {
        get {
            if walletNameTextField.text?.isMandatoryValid() == false {
                walletNameValidationView.isHidden = false
                return false
            }
            
            return true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupNavigationItem()
        setupPublicKeyLabel()
    }
    
    @IBAction func copyButtonAction(_ sender: UIButton) {
        if let value = publicKeyValueLabel.text {
            UIPasteboard.general.string = value
            let alert = UIAlertController(title: nil, message: "Copied to clipboard", preferredStyle: .actionSheet)
            self.present(alert, animated: true)
            alert.dismiss(animated: true)
        }
    }
    
    @IBAction func addButtonAction(_ sender: UIButton) {
        walletNameValidationView.isHidden = true
        if isWalletNameValid {
            addWallet()
        }
    }
    
    @IBAction func cancelButtonAction(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func didTapHelp(_ sender: Any) {
    }
    
    private func setupView() {
        view.backgroundColor = Stylesheet.color(.veryLightGray)
        addButton.backgroundColor = Stylesheet.color(.green)
        cancelButton.backgroundColor = Stylesheet.color(.gray)
    }
    
    private func setupPublicKeyLabel() {
        publicKeyValueLabel.text = PrivateKeyManager.getPublicKey(forIndex: walletCount)
    }
    
    private func addWallet() {
        if let publicKey = publicKeyValueLabel.text,
            let walletName = walletNameTextField.text {
            walletService.addWallet(publicKey: publicKey, name: walletName, showOnHomescreen: showOnHomescreenSwitch.isOn) { (response) -> (Void) in
                switch response {
                case .success:
                    print("Successfully added the wallet!")
                case .failure(error: let error):
                    print("Failed adding wallet! Error: \(error.localizedDescription)")
                }
                
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    private func setupNavigationItem() {
        navigationItem.titleLabel.text = "Add new Wallet"
        navigationItem.titleLabel.textColor = Stylesheet.color(.white)
        navigationItem.titleLabel.font = R.font.encodeSansSemiBold(size: 15)
        
        let helpButton = Material.IconButton()
        helpButton.image = R.image.question()?.crop(toWidth: 15, toHeight: 15)?.tint(with: Stylesheet.color(.white))
        helpButton.addTarget(self, action: #selector(didTapHelp(_:)), for: .touchUpInside)
        navigationItem.rightViews = [helpButton]
    }
}
