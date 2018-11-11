//
//  ReceivePaymentCardViewController.swift
//  Lumenshine
//
//  Created by Razvan Chelemen on 20/07/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import MessageUI
import Material
import stellarsdk

class ReceivePaymentCardViewController: UIViewController, WalletActionsProtocol {
    @IBOutlet weak var qrImageView: UIImageView!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var issuerTextField: UITextField!
    @IBOutlet weak var currencyTextField: UITextField!
    
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var assetCodeLabel: UILabel!
    @IBOutlet weak var publicKeyLabel: UILabel!
    @IBOutlet weak var nativeCurrencyLabel: UILabel!
    @IBOutlet weak var nativeCurrencyValueLabel: UILabel!
    
    @IBOutlet weak var federationAddressView: UIView!
    @IBOutlet weak var nativeCurrencyView: UIView!
    @IBOutlet weak var currencyView: UIView!
    @IBOutlet weak var issuerSeparatorView: UIView!
    @IBOutlet weak var issuerSubtitleView: UIView!
    @IBOutlet weak var issuerValueView: UIView!
    
    @IBOutlet weak var sendByEmailButton: UIButton!
    @IBOutlet weak var printButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    
    private var currencyPickerView: UIPickerView!
    private var issuerPickerView: UIPickerView!
    
    var wallet: Wallet!
    var closeAction: (() -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        populateViews()
        setCurrencies()
        setupTextFields()
        setupNavigationItem()
        view.backgroundColor = Stylesheet.color(.veryLightGray)
        updateQRCode()
    }
    
    override func resignFirstResponder() -> Bool {
        return false
    }

    @IBAction func didTapClose(_ sender: Any) {
        closeAction?()
    }

    @IBAction func amountEditingChanged(_ sender: Any) {
        updateQRCode()
    }
    
    @IBAction func didTapCopyButton(_ sender: UIButton) {
        if let key = publicKeyLabel.text {
            UIPasteboard.general.string = key
            let alert = UIAlertController(title: nil, message: "Copied to clipboard", preferredStyle: .actionSheet)
            self.present(alert, animated: true)
            let when = DispatchTime.now() + 1
            DispatchQueue.main.asyncAfter(deadline: when){
                alert.dismiss(animated: true)
            }
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
        publicKeyLabel.text = wallet.publicKey

        if !wallet.federationAddress.isEmpty {
            emailLabel.text = wallet.federationAddress
        } else {
            federationAddressView.isHidden = true
        }
    }
    
    private func setupTextFields() {
        if let wallet = wallet as? FundedWallet {
            currencyPickerView = UIPickerView()
            currencyPickerView.delegate = self
            currencyPickerView.dataSource = self
            currencyTextField.text = wallet.uniqueAssetCodeBalances.first?.displayCode
            assetCodeLabel.text = wallet.uniqueAssetCodeBalances.first?.displayCode
            currencyTextField.inputView = currencyPickerView
            currencyTextField.keyboardToolbar.doneBarButton.setTarget(self, action: #selector(currencyDoneButtonTap))
            if wallet.hasDuplicateNameCurrencies {
                issuerPickerView = UIPickerView()
                issuerPickerView.delegate = self
                issuerPickerView.dataSource = self
                issuerTextField.text = wallet.uniqueAssetCodeBalances.first?.assetIssuer
                issuerTextField.inputView = issuerPickerView
            }
        }
        
        publicKeyLabel.font = R.font.encodeSansSemiBold(size: 16)
        publicKeyLabel.numberOfLines = 1
        publicKeyLabel.lineBreakMode = .byTruncatingMiddle

        amountTextField.keyboardType = UIKeyboardType.decimalPad
        
        emailLabel.font = R.font.encodeSansSemiBold(size: 16)
        emailLabel.numberOfLines = 0
        
        nativeCurrencyValueLabel.font = R.font.encodeSansSemiBold(size: 15)
    }
    
    private func issuerVisibility(isHidden: Bool) {
        issuerSubtitleView.isHidden = isHidden
        issuerSeparatorView.isHidden = isHidden
        issuerValueView.isHidden = isHidden
    }
    
    private func hideNativeCurrency() {
        nativeCurrencyView.isHidden = true
    }
    
    private func setCurrencies() {
        if let wallet = wallet as? FundedWallet {
            if wallet.hasOnlyNative {
                currencyView.removeFromSuperview()
                issuerVisibility(isHidden: true)
            } else {
                hideNativeCurrency()
                if !wallet.hasDuplicateNameCurrencies {
                    issuerVisibility(isHidden: true)
                }
            }
        }
    }
    
    private func updateQRCode() {
        let value = qrValueString()
        print("QR:" + value)
        if let image = QRCoder.qrCodeImage(qrValueString:value, size:10) {
            qrImageView.image = image
        }
    }
    
    private func qrValueString() -> String {
        let resultObject: NSMutableDictionary = NSMutableDictionary()
        let stellarObject: NSMutableDictionary = NSMutableDictionary()
        let paymentObject: NSMutableDictionary = NSMutableDictionary()
        
        paymentObject.setValue(wallet.publicKey, forKey: "destination")
        if let amount = amountTextField.text, !amount.isEmpty {
            if let dob = Double(amount.replacingOccurrences(of: ",", with: ".")) {
                paymentObject.setValue("\(dob)", forKey: "amount")
            }
        }
        if !Services.shared.usePublicStellarNetwork {
            paymentObject.setValue(Network.testnet.rawValue.sha256().prefix(8), forKey: "network")
        }
        
        if let wallet = wallet as? FundedWallet
        {
            if !wallet.hasOnlyNative, let currency = currencyTextField.text, currency != "XLM" {
                let assetObject: NSMutableDictionary = NSMutableDictionary()
                assetObject.setValue(currency, forKey:"code")
                let issuer = issuerTextField.text ?? ""
                assetObject.setValue(issuer, forKey:"issuer")
                paymentObject.setValue(assetObject, forKey: "asset")
            }
        }
        stellarObject.setValue(paymentObject, forKey: "payment")
        resultObject.setValue(stellarObject, forKey: "stellar")
        
        
        let jsonData: NSData
        
        do {
            jsonData = try JSONSerialization.data(withJSONObject: resultObject, options: JSONSerialization.WritingOptions()) as NSData
            let jsonString = NSString(data: jsonData as Data, encoding: String.Encoding.utf8.rawValue)! as String
            return jsonString
            
        } catch _ {
            print ("JSON Failure")
        }
        
        return wallet.publicKey
    }
    private func emailText() -> String {
        if let wallet = wallet as? FundedWallet {
            var text = "Receive public key: \(publicKeyLabel.text ?? "")\n"
            
            if !wallet.federationAddress.isEmpty {
                text += "Stellar address: \(emailLabel.text ?? "")\n"
            }
            
            if wallet.hasOnlyNative {
                text += "\(nativeCurrencyLabel.text ?? ""): \(nativeCurrencyValueLabel.text ?? "")\nXLM: \(amountTextField.text ?? "0")"
            } else if let currency = currencyTextField.text, currency == "XLM" {
                text += "Currency: \(currencyTextField.text ?? "")\n \(currencyTextField.text ?? ""): \(amountTextField.text ?? "0")"
                
            } else {
                text += "Currency: \(currencyTextField.text ?? "")\nIssuer: \(issuerTextField.text ?? "-")\n\(currencyTextField.text ?? ""): \(amountTextField.text ?? "0")"
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
        if let wallet = wallet as? FundedWallet {
            if pickerView == currencyPickerView {
                if let assetCode = wallet.uniqueAssetCodeBalances[row].displayCode {
                    currencyTextField.text = assetCode
                    assetCodeLabel.text = assetCode
                
                    if wallet.uniqueAssetCodeBalances[row].assetType == AssetTypeAsString.NATIVE  {
                        issuerTextField.text = nil
                        issuerVisibility(isHidden: true)
                    } else {
                        if wallet.isCurrencyDuplicate(withAssetCode: assetCode) {
                            issuerVisibility(isHidden: false)
                        } else {
                            issuerVisibility(isHidden: true)
                        }
                        
                        issuerTextField.text = wallet.issuersFor(assetCode: assetCode)[0]
                    }
                }
            } else if pickerView == issuerPickerView {
                issuerTextField.text = wallet.issuersFor(assetCode: currencyTextField.text!)[row]
            }
        }
    }
    
    @objc func currencyDoneButtonTap(_ sender: Any) {
        selectAsset(pickerView: currencyPickerView, row: currencyPickerView.selectedRow(inComponent: 0))
        updateQRCode()
    }
    
    @IBAction func didTapBack(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func didTapHelp(_ sender: Any) {
        
    }
    
    private func setupNavigationItem() {
        navigationItem.titleLabel.text = "Receive".uppercased()
        navigationItem.titleLabel.textColor = Stylesheet.color(.white)
        navigationItem.titleLabel.font = R.font.encodeSansSemiBold(size: 17)
    }
    
    private func setupView() {
        qrImageView.tintColor = Stylesheet.color(.qrCodeTint)
        sendByEmailButton.backgroundColor = Stylesheet.color(.green)
        printButton.backgroundColor = Stylesheet.color(.orange)
        doneButton.backgroundColor = Stylesheet.color(.blue)
    }
}

extension ReceivePaymentCardViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if let wallet = wallet as? FundedWallet {
            if pickerView == currencyPickerView {
                return wallet.uniqueAssetCodeBalances.count
            } else if pickerView == issuerPickerView {
                return wallet.issuersFor(assetCode: currencyTextField.text!).count
            }
        }
        
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if let wallet = wallet as? FundedWallet {
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
