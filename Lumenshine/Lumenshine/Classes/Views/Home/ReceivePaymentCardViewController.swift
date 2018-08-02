//
//  ReceivePaymentCardViewController.swift
//  Lumenshine
//
//  Created by Razvan Chelemen on 20/07/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import MessageUI

class ReceivePaymentCardViewController: UIViewController {
    @IBOutlet weak var publicKeyButton: UIButton!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var defaultCurrencyView: UIStackView!
    @IBOutlet weak var xlmCurrencyView: UIStackView!
    @IBOutlet weak var currencyView: UIStackView!
    @IBOutlet weak var issuerView: UIStackView!
    @IBOutlet weak var currencyValueView: UIStackView!
    @IBOutlet weak var qrImageView: UIImageView!
    @IBOutlet weak var nativeCurrencyLabel: UILabel!
    @IBOutlet weak var nativeCurrencyValueLabel: UILabel!
    @IBOutlet weak var fieldsStackView: UIStackView!
    
    @IBOutlet weak var xlmValueTextField: UITextField!
    @IBOutlet weak var currencyTextField: UITextField!
    @IBOutlet weak var issuerTextField: UITextField!
    @IBOutlet weak var currencyValueTextField: UITextField!
    @IBOutlet weak var currencyLabel: UILabel!
    
    @IBOutlet weak var stellarAddressContainerHeight: NSLayoutConstraint!
    
    private var currencyPickerView: UIPickerView!
    private var issuerPickerView: UIPickerView!
    
    var wallet: Wallet!
    var closeAction: (() -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        populateViews()
        setCurrencies()
        setupTextFields()
    }
    
    override func resignFirstResponder() -> Bool {
        return false
    }

    @IBAction func didTapClose(_ sender: Any) {
        closeAction?()
    }
    
    @IBAction func didTapPublicKey(_ sender: Any) {
        if let key = publicKeyButton.titleLabel?.text {
            UIPasteboard.general.string = key
        }
    }
    
    @IBAction func didTapSendEmail(_ sender: Any) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self;
            mail.setSubject("Payment data")
            mail.setMessageBody(emailText(), isHTML: false)
            if let image = qrImageView.image, let imageData = UIImagePNGRepresentation(image) {
                mail.addAttachmentData(imageData, mimeType: "image/png", fileName: "qr_code.png")
                self.present(mail, animated: true, completion: nil)
            }
        } else {
            let alert = UIAlertController(title: "Alert", message: "Email not set up!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func didTapPrint(_ sender: Any) {
        let printInfo = UIPrintInfo(dictionary:nil)
        printInfo.outputType = UIPrintInfoOutputType.general
        printInfo.jobName = "Payment data print"
        
        // Set up print controller
        let printController = UIPrintInteractionController.shared
        printController.printInfo = printInfo
        
        // Assign a UIImage version of my UIView as a printing iten
        printController.printingItem = printImage()
        
        // Do it
        printController.present(from: self.view.frame, in: self.view, animated: true, completionHandler: nil)
    }
    
    @IBAction func didTapDone(_ sender: Any) {
        closeAction?()
    }
    
    private func populateViews() {
        publicKeyButton.titleLabel?.numberOfLines = 0
        publicKeyButton.setTitle(wallet.publicKey, for: .normal)
        
        if !wallet.federationAddress.isEmpty {
            emailLabel.text = wallet.federationAddress
        } else {
            stellarAddressContainerHeight.priority = .required
        }
    }
    
    private func setupTextFields() {
        if let wallet = wallet as? FoundedWallet {
            currencyPickerView = UIPickerView()
            currencyPickerView.delegate = self
            currencyPickerView.dataSource = self
            currencyTextField.text = wallet.balances.first?.displayCode
            currencyLabel.text = wallet.balances.first?.displayCode
            currencyTextField.inputView = currencyPickerView
            currencyTextField.keyboardToolbar.doneBarButton.setTarget(self, action: #selector(currencyDoneButtonTap))
            if wallet.hasDuplicateNameCurrencies {
                issuerPickerView = UIPickerView()
                issuerPickerView.delegate = self
                issuerPickerView.dataSource = self
                issuerTextField.text = wallet.balances.first?.assetIssuer
                issuerTextField.inputView = issuerPickerView
            }
            currencyValueTextField.text = wallet.balances.first?.balance
        }
    }
    
    private func setCurrencies() {
        if let wallet = wallet as? FoundedWallet {
            if wallet.hasOnlyNative {
                currencyView.removeFromSuperview()
                issuerView.removeFromSuperview()
                currencyValueView.removeFromSuperview()
            } else {
                defaultCurrencyView.removeFromSuperview()
                xlmCurrencyView.removeFromSuperview()
                if !wallet.hasDuplicateNameCurrencies {
                    issuerView.removeFromSuperview()
                }
            }
        }
    }
    
    private func emailText() -> String {
        if let wallet = wallet as? FoundedWallet {
            var text = "Receive public key: \(publicKeyButton.titleLabel?.text ?? "")\n"
            
            if !wallet.federationAddress.isEmpty {
                text += "Stellar address: \(emailLabel.text ?? "")\n"
            }
            
            if wallet.hasOnlyNative {
                text += "\(nativeCurrencyLabel.text ?? ""): \(nativeCurrencyValueLabel.text ?? "")\nXLM: \(xlmValueTextField.text ?? "0")"
            } else if !wallet.hasDuplicateNameCurrencies {
                text += "Currency: \(currencyTextField.text ?? "")\n \(currencyTextField.text ?? ""): \(currencyValueTextField.text ?? "0")"
            } else {
                text += "Currency: \(currencyTextField.text ?? "")\nIssuer: \(issuerTextField.text ?? "-")\n\(currencyTextField.text ?? ""): \(currencyValueTextField.text ?? "0")"
            }
            
            return text
        }
        
        return ""
    }
    
    private func printImage() -> UIImage? {
        let bounds = UIScreen.main.bounds
        //        let webView = WKWebView(frame: CGRect(x: 9999, y: 9999, width: bounds.width, height: bounds.height), configuration: webConfiguration)
        //        webView.loadHTMLString(self, baseURL: nil)
        let view = Bundle.main.loadNibNamed("ReceivePaymentPrintView", owner: nil, options: nil)![0] as! ReceivePaymentPrintView
        view.frame = CGRect(x: 9999, y: 9999, width: bounds.width, height: bounds.height)
        view.label.text = emailText()
        view.imageView.image = qrImageView.image
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.addSubview(view)
        let image = view.toImage()
        view.removeFromSuperview()
        
        return image
    }
    
    fileprivate func selectAsset(pickerView: UIPickerView, row: Int) {
        if let wallet = wallet as? FoundedWallet {
            if pickerView == currencyPickerView {
                currencyTextField.text = wallet.uniqueAssetCodeBalances[row].displayCode
                currencyLabel.text = wallet.uniqueAssetCodeBalances[row].displayCode
                
                if wallet.uniqueAssetCodeBalances[row].assetType == "native" {
                    issuerTextField.text = nil
                } else {
                    issuerTextField.text = wallet.issuersFor(assetCode: currencyTextField.text!)[0]
                }
            } else if pickerView == issuerPickerView {
                issuerTextField.text = wallet.issuersFor(assetCode: currencyTextField.text!)[row]
            }
        }
    }
    
    @objc func currencyDoneButtonTap(_ sender: Any) {
        selectAsset(pickerView: currencyPickerView, row: currencyPickerView.selectedRow(inComponent: 0))
    }
    
}

extension ReceivePaymentCardViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if let wallet = wallet as? FoundedWallet {
            if pickerView == currencyPickerView {
                return wallet.uniqueAssetCodeBalances.count
            } else if pickerView == issuerPickerView {
                return wallet.issuersFor(assetCode: currencyTextField.text!).count
            }
        }
        
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if let wallet = wallet as? FoundedWallet {
            if pickerView == currencyPickerView {
                return wallet.uniqueAssetCodeBalances[row].displayCode
            } else if pickerView == issuerPickerView {
                return wallet.issuersFor(assetCode: currencyTextField.text!)[row]
            }
        }
        
        return nil
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectAsset(pickerView: pickerView, row: row)
    }
    
}

extension ReceivePaymentCardViewController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
}
