//
//  TransactionResultViewController.swift
//  Lumenshine
//
//  Created by Soneso on 06/08/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation
import UIKit
import Material

enum ButtonsSuccessTitles: String {
    case editOrSendOtherButton = "Send other"
    case sendOtherOrPrintButton = "Print"
    case printOrDoneButton = "Done"
}

enum ButtonsErrorTitles: String {
    case editOrSendOtherButton = "Edit"
    case sendOtherOrPrintButton = "Send other"
    case printOrDoneButton = "Print"
}

enum StatusLabelText: String {
    case success = "success"
    case error = "error"
}

var TransactionResultPrintJobName = "Transaction result print data"

class TransactionResultViewController: UIViewController, WalletActionsProtocol {
    @IBOutlet weak var statusValueLabel: UILabel!
    @IBOutlet weak var messageValueLabel: UILabel!
    @IBOutlet weak var currencyValueLabel: UILabel!
    @IBOutlet weak var issuerValueLabel: UILabel!
    @IBOutlet weak var amountValueLabel: UILabel!
    @IBOutlet weak var recipientMailValueLabel: UILabel!
    @IBOutlet weak var recipientPKLabel: UILabel!
    @IBOutlet weak var memoValueLabel: UILabel!
    @IBOutlet weak var memoTypeValueLabel: UILabel!
    @IBOutlet weak var transactionFeeValueLabel: UILabel!
    @IBOutlet weak var operationIDValueLabel: UILabel!
    
    @IBOutlet weak var errorMessageStackView: UIStackView!
    @IBOutlet weak var operationIDStackView: UIStackView!
    @IBOutlet weak var doneWithErrorsStackView: UIStackView!
    @IBOutlet weak var transactionFeeStackView: UIStackView!
    @IBOutlet weak var memoStackView: UIStackView!
    @IBOutlet weak var memoTypeStackView: UIStackView!
    @IBOutlet weak var issuerLabelStackView: UIStackView!
    @IBOutlet weak var issuerValueStackView: UIStackView!
    
    @IBOutlet weak var editOrSendOtherButton: UIButton!
    @IBOutlet weak var sendOtherOrPrintButton: UIButton!
    @IBOutlet weak var printOrDoneButton: UIButton!
    
    var wallet: Wallet!
    var result: TransactionResult!
    var closeAction: (() -> ())?
    var sendOtherAction: (() -> ())?
    var closeAllAction: (() -> ())?
    
    private var titleView = TitleView()
    
    @IBAction func closeButtonAction(_ sender: UIButton) {
        switch result.status {
        case .error:
            closeAction?()
            break
        case .success:
            closeAllAction?()
            break
        }
    }
  
    @IBAction func editOrSendOtherButtonAction(_ sender: UIButton) {
        switch result.status {
        case .error:
            closeAction?()
            break
        case .success:
            sendOtherAction?()
            break
        }
    }
    
    @IBAction func sendOtherOrPrintButtonAction(_ sender: UIButton) {
        switch result.status {
        case .error:
            sendOtherAction?()
            break
        case.success:
            print()
            break
        }
    }
    
    @IBAction func printOrDoneButtonAction(_ sender: UIButton) {
        switch result.status {
        case .error:
            print()
            break
        case.success:
            closeAllAction?()
            break
        }
    }
    
    @IBAction func doneButtonAction(_ sender: UIButton) {
        closeAllAction?()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch result.status {
        case .error:
            operationIDStackView.isHidden = true
            if result.transactionFee == nil {
                transactionFeeStackView.isHidden = true
            }
        case .success:
            doneWithErrorsStackView.isHidden = true
            errorMessageStackView.isHidden = true
        }
        
        if result.currency == NativeCurrencyNames.xlm.rawValue {
            issuerLabelStackView.isHidden = true
            issuerValueStackView.isHidden = true
        }
        
        if result.memo == nil {
            memoStackView.isHidden = true
            memoTypeStackView.isHidden = true
        }
        
        setButtonsTitles()
        setStatusLabel()
        populateValues()
        setupNavigationItem()
    }
    
    private func setStatusLabel() {
        switch result.status {
        case .error:
            statusValueLabel.text = StatusLabelText.error.rawValue
            statusValueLabel.textColor = Stylesheet.color(.red)
            break
        case .success:
            statusValueLabel.text = StatusLabelText.success.rawValue
            statusValueLabel.textColor = Stylesheet.color(.green)
            break
        }
    }
    
    private func setButtonsTitles() {
        switch result.status {
        case .error:
            editOrSendOtherButton.setTitle(ButtonsErrorTitles.editOrSendOtherButton.rawValue, for: UIControlState.normal)
            sendOtherOrPrintButton.setTitle(ButtonsErrorTitles.sendOtherOrPrintButton.rawValue, for: UIControlState.normal)
            printOrDoneButton.setTitle(ButtonsErrorTitles.printOrDoneButton.rawValue, for: UIControlState.normal)
            break
        case.success:
            editOrSendOtherButton.setTitle(ButtonsSuccessTitles.editOrSendOtherButton.rawValue, for: UIControlState.normal)
            sendOtherOrPrintButton.setTitle(ButtonsSuccessTitles.sendOtherOrPrintButton.rawValue, for: UIControlState.normal)
            printOrDoneButton.setTitle(ButtonsSuccessTitles.printOrDoneButton.rawValue, for: UIControlState.normal)
            break
        }
    }
    
    private func populateValues() {
        messageValueLabel.text = result.message
        currencyValueLabel.text = result.currency
        issuerValueLabel.text = result.issuer
        amountValueLabel.text = "\(result.amount) \(result.currency)"
        recipientMailValueLabel.text = result.recipentMail
        recipientPKLabel.text = result.recipentPK
        memoValueLabel.text = result.memo
        memoTypeValueLabel.text = result.memoType.rawValue
        transactionFeeValueLabel.text = "\(result.transactionFee ?? "") \(NativeCurrencyNames.xlm.rawValue)"
        operationIDValueLabel.text = result.operationID
    }
    
    private func getPrintingText() -> String {
        var resultString: String = ""
        
        if let status = statusValueLabel.text {
            resultString.append("Status: \(status)\n")
        }
        
        if let message = messageValueLabel.text {
            resultString.append(message.isEmpty == false ? "Message: \(message)\n" : "")
        }
        
        if let currency = currencyValueLabel.text {
            resultString.append("Currency \(currency)\n")
            
            if let issuer = issuerValueLabel.text {
                resultString.append(currency != NativeCurrencyNames.xlm.rawValue && !issuer.isEmpty ? "Issuer: \(issuer)\n" : "")
            }
        }
        
        if let amount = amountValueLabel.text {
            resultString.append("Amount: \(amount)\n")
        }
        
        if let recipientMail = recipientMailValueLabel.text {
            resultString.append("Recipient: \(recipientMail)\n")
        }
        
        if let recipientPK = recipientPKLabel.text {
            resultString.append("\(recipientPK)\n")
        }
        
        if let memo = memoValueLabel.text {
            resultString.append(!memo.isEmpty ? "Memo: \(memo)\n" : "")
            
            if let memoType = memoTypeValueLabel.text {
                resultString.append(!memo.isEmpty && !memoType.isEmpty ? "Memo type: \(memoType)\n" : "")
            }
        }
        
        if let operationID = operationIDValueLabel.text {
            resultString.append(!operationID.isEmpty ? "Operation ID: \(operationID)\n" : "")
        }
        
        if let transactionFee = transactionFeeValueLabel.text {
            resultString.append(!transactionFee.isEmpty ? "Transaction fee: \(transactionFee)" : "")
        }
        
        return resultString
    }
    
    private func print() {
        let printInfo = UIPrintInfo(dictionary:nil)
        printInfo.outputType = UIPrintInfoOutputType.general
        printInfo.jobName = TransactionResultPrintJobName
        
        let printController = UIPrintInteractionController.shared
        printController.printInfo = printInfo
        printController.printingItem = getPrintingItem()
        printController.present(from: self.view.frame, in: self.view, animated: true, completionHandler: nil)
    }
    
    private func getPrintingItem() -> UIImage? {
        let bounds = UIScreen.main.bounds
        let view = Bundle.main.loadNibNamed("TransactionResultPrintView", owner: nil, options: nil)![0] as! TransactionResultPrintView
        view.frame = CGRect(x: 9999, y: 9999, width: bounds.width, height: bounds.height)
        view.contentsLabel.text = getPrintingText()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.addSubview(view)
        let image = view.toImage()
        view.removeFromSuperview()
        
        return image
    }
    
    @IBAction func didTapBack(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func didTapHelp(_ sender: Any) {
        
    }
    
    private func setupNavigationItem() {
        navigationItem.titleLabel.text = "Transaction result"
        navigationItem.titleLabel.textColor = Stylesheet.color(.white)
        navigationItem.titleLabel.font = R.font.encodeSansSemiBold(size: 15)
    }
}
