//
//  WalletsView.swift
//  Lumenshine
//
//  Created by Soneso on 04/12/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit

class WalletsView: UIView, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var walletTextField: UITextField!
    private var walletPickerView: UIPickerView!
    
    var walletsList: [Wallet]! {
        didSet {
            setupWalletPicker()
        }
    }
    
    var walletChanged: ((Wallet) -> ())?
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return walletsList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectAsset(pickerView: pickerView, row: row)
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return walletsList[row].name
    }
    
    private func selectAsset(pickerView: UIPickerView, row: Int) {
        let wallet = walletsList[row]
        walletTextField.text = wallet.name
        walletChanged?(wallet)
    }
    
    @objc func walletsDoneButtonTap() {
        selectAsset(pickerView: walletPickerView, row: walletPickerView.selectedRow(inComponent: 0))
    }
    
    private func setupWalletPicker() {
        if walletPickerView == nil {
            walletPickerView = UIPickerView()
            walletPickerView.delegate = self
            walletPickerView.dataSource = self
            walletTextField.inputView = walletPickerView
            walletTextField.keyboardToolbar.doneBarButton.setTarget(self, action: #selector(walletsDoneButtonTap))
        }
        
        walletTextField.text = walletsList.first?.name
    }
}
