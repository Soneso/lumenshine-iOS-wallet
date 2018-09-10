//
//  SendViewController.swift
//  Lumenshine
//
//  Created by Soneso on 02/08/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation
import UIKit
import stellarsdk

enum ValidationErrors: String {
    case Mandatory = "Mandatory"
    case InvalidAddress = "Invalid public key or address"
    case InvalidMemo = "Invalid memo"
    case MemoLength = "Memo is too long"
    case InsufficientLumens = "Insufficient XLM for transaction fee available"
    case RecipientAccount = "Warning: Recipient account does not exist or is not funded"
    case CurrencyNoTrust = "Recipient can not receive selected currency"
    case AddressNotFound = "Address not found"
    case InvalidPassword = "Invalid password"
    case MandatoryPassword = "Password required"
}

enum MemoTypeValues: String {
    case MEMO_TEXT = "MEMO_TEXT"
    case MEMO_ID = "MEMO_ID"
    case MEMO_HASH = "MEMO_HASH"
    case MEMO_RETURN = "MEMO_RETURN"
}

enum MemoTextFieldPlaceholders: String {
    case MemoText = "Up to 28 characters"
    case MemoID = "Enter memo ID number"
    case MemoHash, MemoReturn = "Enter 64 characters encoded string"
}

enum NativeCurrencyNames: String {
    case xlm = "XLM"
    case stellarLumens = "Stellar Lumens (XLM)"
}

enum SendButtonTitles: String {
    case sendAnyway = "Send anyway"
    case validating = "Validating and sending"
}

public let MaximumLengthInBytesForMemoText = 28
public let QRCodeSeparationString = " "
public let QRCodeNativeCurrencyIssuer = "native"

class SendViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, WalletActionsProtocol, ScanViewControllerDelegate, NavigationItemProtocol {
    @IBOutlet weak var currentCurrencyLabel: UILabel!
    @IBOutlet weak var addressErrorLabel: UILabel!
    @IBOutlet weak var amountErrorLabel: UILabel!
    @IBOutlet weak var memoInputErrorLabel: UILabel!
    @IBOutlet weak var passwordErrorLabel: UILabel!
    @IBOutlet weak var sendErrorLabel: UILabel!
    
    @IBOutlet weak var memoTypeTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var memoInputTextField: UITextField!
    @IBOutlet weak var issuerTextField: UITextField!
    @IBOutlet weak var currentCurrencyTextField: UITextField!
    
    @IBOutlet weak var currencyStackView: UIStackView!
    @IBOutlet weak var addressErrorStackView: UIStackView!
    @IBOutlet weak var amountErrorStackView: UIStackView!
    @IBOutlet weak var memoInputErrorStackView: UIStackView!
    @IBOutlet weak var passwordErrorStackView: UIStackView!
    @IBOutlet weak var sendErrorStackView: UIStackView!
    @IBOutlet weak var issuerStackView: UIStackView!
    
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var qrImageView: UIImageView!
    
    private var currencyPickerView: UIPickerView!
    private var issuerPickerView: UIPickerView!
    private var memoTypePickerView: UIPickerView!
    
    private var titleView = TitleView()
    
    private var isInputDataValid: Bool = true
    private var isSendAnywayRequired = false
    private var userMnemonic: String!
    
    var wallet: Wallet!
    var closeAction: (() -> ())?
    var sendAction: ((TransactionInput) -> ())?
    var navigationSetupRequired = false
    
    private var scanViewController: ScanViewController!
    private let inputDataValidator = InputDataValidator()
    
    private var memoTypes: [MemoTypeValues] = [MemoTypeValues.MEMO_TEXT, MemoTypeValues.MEMO_ID, MemoTypeValues.MEMO_HASH, MemoTypeValues.MEMO_RETURN]
    
    @IBAction func closeButtonAction(_ sender: UIButton) {
        closeAction?()
    }
    
    @objc func addressChanged(_ textField: UITextField) {
        if isSendAnywayRequired {
            setSendButtonDefaultTitle()
            isSendAnywayRequired = false
        }
    }
    
    @IBAction func sendButtonAction(_ sender: UIButton) {
        resetValidations()
        sendButton.setTitle(SendButtonTitles.validating.rawValue, for: UIControlState.normal)
        sendButton.isEnabled = false
            if validateInsertedData() {
                if let address = addressTextField.text,
                    let password = passwordTextField.text,
                    let currency = (wallet as! FoundedWallet).balances.first(where: { (currency) -> Bool in return currency.displayCode == selectedCurrency }) {
                    
                    inputDataValidator.validatePasswordAndDestinationAddress(address: address, password: password, currency: currency) { (result) -> (Void) in
                        switch result {
                        case .success(passwordResponse: let passwordResponse, addressResponse: let addressResponse):
                            self.validatePasswordResponse(passwordResponse: passwordResponse)
                            self.validateAddressResponse(addressResponse: addressResponse)
                            
                            self.checkForRecipientAccount()
                            
                            if self.isInputDataValid {
                                self.sendPayment()
                            } else {
                                self.resetSendButtonToNormal()
                            }
                            
                        case .failure:
                            break
                        }
                    }
                }
            }
            else {
                resetSendButtonToNormal()
        }
    }

    private var selectedMemoType: MemoTypeValues! = MemoTypeValues.MEMO_TEXT {
        didSet {
            memoTypeTextField.text = selectedMemoType.rawValue
            
            switch selectedMemoType.rawValue {
            case MemoTypeValues.MEMO_TEXT.rawValue:
                memoInputTextField.placeholder = MemoTextFieldPlaceholders.MemoText.rawValue
                break
            case MemoTypeValues.MEMO_ID.rawValue:
                memoInputTextField.placeholder = MemoTextFieldPlaceholders.MemoID.rawValue
                break
            case MemoTypeValues.MEMO_HASH.rawValue:
                memoInputTextField.placeholder = MemoTextFieldPlaceholders.MemoHash.rawValue
                break
            case MemoTypeValues.MEMO_RETURN.rawValue:
                memoInputTextField.placeholder = MemoTextFieldPlaceholders.MemoReturn.rawValue
                break
            default:
                break
            }
        }
    }
    
    private var selectedCurrency: String = "" {
        didSet {
            currentCurrencyLabel.text = selectedCurrency
            
            if selectedCurrency == NativeCurrencyNames.xlm.rawValue {
                currentCurrencyTextField.text = NativeCurrencyNames.stellarLumens.rawValue
            } else {
                currentCurrencyTextField.text = selectedCurrency
            }
            
            setSendButtonDefaultTitle()
            
            if (wallet as! FoundedWallet).isCurrencyDuplicate(withAssetCode: selectedCurrency) {
                if issuerPickerView == nil {
                    issuerPickerView = UIPickerView()
                    issuerPickerView.delegate = self
                    issuerPickerView.dataSource = self
                    issuerTextField.inputView = issuerPickerView
                    issuerTextField.keyboardToolbar.doneBarButton.setTarget(self, action: #selector(issuerDoneButtonTap))
                }
                
                issuerStackView.isHidden = false
                issuerTextField.text = (wallet as! FoundedWallet).balances.first?.assetIssuer
            } else {
                issuerStackView.isHidden = true
                issuerTextField.text = nil
            }
        }
    }
    
    @objc func qrScannerTapAction(sender:UITapGestureRecognizer) {
        scanViewController = ScanViewController()
        scanViewController.delegate = self
        self.addChildViewController(scanViewController)
        self.view.addSubview(scanViewController.view)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        memoTypePickerView = UIPickerView()
        memoTypePickerView.delegate = self
        memoTypePickerView.dataSource = self
        memoTypeTextField.text = selectedMemoType.rawValue
        memoTypeTextField.inputView = memoTypePickerView
        memoTypeTextField.keyboardToolbar.doneBarButton.setTarget(self, action: #selector(memoTypeDoneButtonTap))
        addressTextField.addTarget(self, action: #selector(addressChanged), for: UIControlEvents.editingChanged)
        let openQRScannerTap = UITapGestureRecognizer(target: self, action: #selector(qrScannerTapAction))
        qrImageView.addGestureRecognizer(openQRScannerTap)
        
        if navigationSetupRequired {
            setupNavigationItem()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        availableCurrencies = (wallet as! FoundedWallet).getAvailableCurrencies()
        if selectedCurrency.isEmpty {
            selectedCurrency = availableCurrencies.first!
        }
        
        checkForTransactionFeeAvailability()
        resetSendButtonToNormal()
    }
    
    private var availableCurrencies: [String] = [""] {
        didSet {
            if availableCurrencies.count > 1 {
                currencyPickerView = UIPickerView()
                currencyPickerView.delegate = self
                currencyPickerView.dataSource = self
                currentCurrencyTextField.inputView = currencyPickerView
                currentCurrencyTextField.keyboardToolbar.doneBarButton.setTarget(self, action: #selector(currencyDoneButtonTap))
            } else {
                currencyStackView.isHidden = true
            }
        }
    }
    
    @objc func currencyDoneButtonTap(_ sender: Any) {
        selectAsset(pickerView: currencyPickerView, row: currencyPickerView.selectedRow(inComponent: 0))
    }
    
    @objc func memoTypeDoneButtonTap(_ sender: Any) {
        selectAsset(pickerView: memoTypePickerView, row: memoTypePickerView.selectedRow(inComponent: 0))
    }
    
    @objc func issuerDoneButtonTap(_ sender: Any) {
        selectAsset(pickerView: issuerPickerView, row: issuerPickerView.selectedRow(inComponent: 0))
    }
    
    private func sendPayment() {
        let transactionData = TransactionInput(currency: self.selectedCurrency,
                                               issuer: self.issuerTextField.text ?? nil,
                                               address: self.addressTextField.text ?? "",
                                               amount: self.amountTextField.text ?? "",
                                               memo: self.memoInputTextField.text?.isEmpty == false ? self.memoInputTextField.text! : nil,
                                               memoType: self.memoTypes.first(where: { (memoType) -> Bool in
                                                if let memoTypeTextFieldValue = self.memoTypeTextField.text {
                                                    return memoType.rawValue == memoTypeTextFieldValue
                                                }
                                                
                                                return memoType.rawValue == MemoTypeValues.MEMO_TEXT.rawValue
                                               }),
                                               userMnemonic: self.userMnemonic,
                                               transactionType: !self.isSendAnywayRequired ? TransactionActionType.sendPayment : TransactionActionType.createAndFundAccount )
        
        self.sendAction?(transactionData)
    }
    
    private func validatePasswordResponse(passwordResponse: PasswordEnum) {
        switch passwordResponse {
        case .success(mnemonic: let mnemonic):
            self.userMnemonic = mnemonic
        case .failure(error: let error):
            print("Error: \(error)")
            self.setValidationError(stackView: self.passwordErrorStackView, label: self.passwordErrorLabel, errorMessage: ValidationErrors.InvalidPassword)
        }
    }
    
    private func validateAddressResponse(addressResponse: AddressStatusEnum) {
        switch addressResponse {
        case .success(isFunded: let isFunded, isTrusted: let isTrusted):
            if !isFunded {
                self.setValidationError(stackView: self.sendErrorStackView, label: self.sendErrorLabel, errorMessage: ValidationErrors.RecipientAccount)
                
                if self.selectedCurrency == NativeCurrencyNames.xlm.rawValue {
                    self.isSendAnywayRequired = true
                }
            } else if let isTrusted = isTrusted, !isTrusted {
                self.setValidationError(stackView: self.addressErrorStackView, label: self.addressErrorLabel, errorMessage: ValidationErrors.CurrencyNoTrust)
            }
            
        case .failure:
            print("Account not found")
            if self.selectedCurrency == NativeCurrencyNames.xlm.rawValue {
                self.setValidationError(stackView: self.sendErrorStackView, label: self.sendErrorLabel, errorMessage: ValidationErrors.RecipientAccount)
                self.isSendAnywayRequired = true
            } else {
                self.setValidationError(stackView: self.addressErrorStackView, label: self.addressErrorLabel, errorMessage: ValidationErrors.AddressNotFound)
            }
        }
    }
    
    private func getSendButtonDefaultTitle() -> String {
        return "Send \(selectedCurrency)"
    }
    
    private func setSendButtonDefaultTitle() {
        let sendButtonTitle: String = getSendButtonDefaultTitle()
        sendButton.setTitle(sendButtonTitle, for: .normal)
    }
    
    private func checkForTransactionFeeAvailability() {
        if (wallet as! FoundedWallet).nativeBalance.availableAmount.isLess(than: CoinUnit.Constants.transactionFee + CoinUnit.Constants.baseReserver) {
            sendErrorStackView.isHidden = false
            sendErrorLabel.text = ValidationErrors.InsufficientLumens.rawValue
            sendButton.isEnabled = false
        }
    }
    
    private func resetValidations() {
        addressErrorStackView.isHidden = true
        addressErrorLabel.text = nil
        amountErrorStackView.isHidden = true
        amountErrorLabel.text = nil
        memoInputErrorStackView.isHidden = true
        memoInputErrorLabel.text = nil
        passwordErrorStackView.isHidden = true
        passwordErrorLabel.text = nil
        sendErrorStackView.isHidden = true
        sendErrorLabel.text = nil
        isInputDataValid = true
        setSendButtonDefaultTitle()
    }
    
    private func setValidationError(stackView: UIStackView, label: UILabel, errorMessage: ValidationErrors) {
        stackView.isHidden = false
        label.text = errorMessage.rawValue
        
        isInputDataValid = false
    }
    
    private func validateAddress() {
        if let address = addressTextField.text {
            if !address.isMandatoryValid() {
                setValidationError(stackView: addressErrorStackView, label: addressErrorLabel, errorMessage: ValidationErrors.Mandatory)
                return
            }
            
            if address.isFederationAddress() {
                return
            }
            
            if !address.isBase64Valid() {
                setValidationError(stackView: addressErrorStackView, label: addressErrorLabel, errorMessage: ValidationErrors.InvalidAddress)
            }
        }
    }
    
    private func validateAmount() {
        if let amountToValidate = self.amountTextField.text {
            if !amountToValidate.isMandatoryValid() {
                setValidationError(stackView: amountErrorStackView, label: amountErrorLabel, errorMessage: ValidationErrors.Mandatory)
                return
            }
            
            if let balance: String = (wallet as! FoundedWallet).balances.first(where: { (balance) -> Bool in
                return balance.displayCode == selectedCurrency})?.balance {
            if !amountToValidate.isAmountValid(forBalance: balance) {
                amountErrorStackView.isHidden = false
                amountErrorLabel.text = "Insufficient \(selectedCurrency) available"
                isInputDataValid = false
                }
            }
        }
    }
    
    private func validateMemo() {
        if let memoText = self.memoInputTextField.text {
            if memoText.isEmpty == true {
                return
            }
            
            switch selectedMemoType.rawValue {
            case MemoTypeValues.MEMO_TEXT.rawValue:
                let memoTextValidationResult: MemoTextValidationResult = memoText.isMemoTextValid(limitNrOfBytes: MaximumLengthInBytesForMemoText)
                
                if memoTextValidationResult == MemoTextValidationResult.InvalidEncoding {
                    setValidationError(stackView: memoInputErrorStackView, label: memoInputErrorLabel, errorMessage: ValidationErrors.InvalidMemo)
                    return
                }
                
                if memoTextValidationResult == MemoTextValidationResult.InvalidLength {
                    setValidationError(stackView: memoInputErrorStackView, label: memoInputErrorLabel, errorMessage: ValidationErrors.MemoLength)
                    return
                }
                
            case MemoTypeValues.MEMO_ID.rawValue:
                if !memoText.isMemoIDValid() {
                    setValidationError(stackView: memoInputErrorStackView, label: memoInputErrorLabel, errorMessage: ValidationErrors.InvalidMemo)
                }
                
            case MemoTypeValues.MEMO_HASH.rawValue:
                if !memoText.isMemoHashValid() {
                    setValidationError(stackView: memoInputErrorStackView, label: memoInputErrorLabel, errorMessage: ValidationErrors.InvalidMemo)
                }
                
            case MemoTypeValues.MEMO_RETURN.rawValue:
                if !memoText.isMemoReturnValid() {
                    setValidationError(stackView: memoInputErrorStackView, label: memoInputErrorLabel, errorMessage: ValidationErrors.InvalidMemo)
                }
                
            default:
                break
            }
        }
    }
    
    
    
    private func validatePassword() {
        if let currentPassword = passwordTextField.text {
            if !currentPassword.isMandatoryValid() {
                setValidationError(stackView: passwordErrorStackView, label: passwordErrorLabel, errorMessage: ValidationErrors.Mandatory)
                return
            }
            
            if !isInputDataValid {
                return
            }
        }
    }
    
    private func checkForRecipientAccount() {
        if !isInputDataValid || isSendAnywayRequired {
            if isSendAnywayRequired {
                isInputDataValid = true
            }

            return
        }
    }
    
    private func validateInsertedData() -> Bool {
        validateAddress()
        validateAmount()
        validateMemo()
        validatePassword()
        checkForTransactionFeeAvailability()
        checkForRecipientAccount()
        
        return isInputDataValid
    }
    
    func setQR(value: String) {
        // QR Valid Structure:
        // Currency: XML
        // Issuer: KAJSHDJAS.../native
        // Address: KJSAHDJKASH...
        // Amount: 500
        // MemoType: none/text/id/hash/return
        // Memo: none/value
        // Password: asdfdasjkd
        
        // Example: XML native me@me.me 500 none none 1234
        
        let qrResultArray = value.components(separatedBy: QRCodeSeparationString)
        
        if qrResultArray.count != 7 {
            scanViewController.view.removeFromSuperview()
            scanViewController = nil
            return
        }
        
        self.currentCurrencyTextField.text = qrResultArray[0]
        self.issuerTextField.text = qrResultArray[1] != QRCodeNativeCurrencyIssuer ? qrResultArray[1] : nil
        self.addressTextField.text = qrResultArray[2]
        self.amountTextField.text = qrResultArray[3]
        
        switch qrResultArray[4] {
        case MemoTypeAsString.TEXT:
            self.memoTypeTextField.text = MemoTypeValues.MEMO_TEXT.rawValue
            break
        case MemoTypeAsString.ID:
            self.memoTypeTextField.text = MemoTypeValues.MEMO_ID.rawValue
            break
        case MemoTypeAsString.HASH:
            self.memoTypeTextField.text = MemoTypeValues.MEMO_HASH.rawValue
            break
        case MemoTypeAsString.RETURN:
            self.memoTypeTextField.text = MemoTypeValues.MEMO_RETURN.rawValue
            break
        default:
            break
        }
        
        if qrResultArray[5] != MemoTypeAsString.NONE {
            self.memoInputTextField.text = qrResultArray[5]
        }
        
        self.passwordTextField.text = qrResultArray[6]
        scanViewController.view.removeFromSuperview()
        scanViewController = nil
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == currencyPickerView {
            return availableCurrencies.count
        } else if pickerView == memoTypePickerView {
            return memoTypes.count
        } else if pickerView == issuerPickerView {
            return (wallet as! FoundedWallet).issuersFor(assetCode: selectedCurrency).count
        }
        
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == currencyPickerView {
            if availableCurrencies[row] == NativeCurrencyNames.xlm.rawValue {
                return NativeCurrencyNames.stellarLumens.rawValue
            }
            return availableCurrencies[row]
        } else if pickerView == memoTypePickerView {
            return memoTypes[row].rawValue
        } else if pickerView == issuerPickerView {
            return (wallet as! FoundedWallet).issuersFor(assetCode: selectedCurrency)[row]
        }
        
        return nil
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectAsset(pickerView: pickerView, row: row)
    }
    
    @IBAction func didTapBack(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func didTapHelp(_ sender: Any) {
        
    }
    
    private func selectAsset(pickerView: UIPickerView, row: Int) {
        if pickerView == currencyPickerView {
        selectedCurrency = availableCurrencies[row]
        return
        } else if pickerView == memoTypePickerView {
            selectedMemoType = memoTypes[row]
            return
        } else if pickerView == issuerPickerView {
            issuerTextField.text = (wallet as! FoundedWallet).issuersFor(assetCode: selectedCurrency)[row]
        }
    }
    
    private func resetSendButtonToNormal() {
        sendButton.setTitle(isSendAnywayRequired ? SendButtonTitles.sendAnyway.rawValue : getSendButtonDefaultTitle(), for: UIControlState.normal)
        sendButton.isEnabled = true
    }
    
    private func setupNavigationItem() {
        titleView = Bundle.main.loadNibNamed("TitleView", owner:self, options:nil)![0] as! TitleView
        titleView.frame.size = titleView.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
        titleView.label.text = "\(wallet.name)\nSend"
        navigationItem.titleView = titleView
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image:UIImage(named: "arrow-left"), style:.plain, target: self, action: #selector(didTapBack(_:)))
        navigationItem.leftBarButtonItem?.tintColor = Stylesheet.color(.white)
        navigationItem.leftBarButtonItem?.imageInsets = UIEdgeInsetsMake(0, 2, 0, -2)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image:UIImage(named: "question"), style:.plain, target: self, action: #selector(didTapHelp(_:)))
        navigationItem.rightBarButtonItem?.tintColor = Stylesheet.color(.white)
        navigationItem.rightBarButtonItem?.imageInsets = UIEdgeInsetsMake(0, 2, 0, -2)
    }
}
