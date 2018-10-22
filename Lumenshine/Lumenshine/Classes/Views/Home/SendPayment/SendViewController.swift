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
import Material

enum ValidationErrors: String {
    case Mandatory = "Mandatory"
    case InvalidAddress = "Invalid public key or address"
    case InvalidMemo = "Invalid memo"
    case MemoLength = "Memo is too long"
    case InsufficientLumens = "Insufficient XLM for transaction fee available"
    case ResolveRecepientAddress = "An error occured while trying to validate recepient address"
    case CurrencyNoTrust = "Recipient can not receive selected currency"
    case AddressNotFound = "Address not found"
    case InvalidPassword = "Invalid password"
    case MandatoryPassword = "Password required"
    case InvalidSignerSeed = "Invalid seed"
    case InvalidAmount = "Invalid amount"
    case InvalidAssetCode = "Invalid asset code"
    case FederationNotFound = "Could not find stellar address"
    case CurrencyNotFound = "Could not find selected currency"
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
    case MemoReturn = "Enter 64 characters encoded string"
}

enum NativeCurrencyNames: String {
    case xlm = "XLM"
    case stellarLumens = "Stellar Lumens (XLM)"
}

enum SendButtonTitles: String {
    case validating = "Validating and sending"
}

enum AmountSegmentedControlIndexes: Int {
    case sendAmount = 0
    case sendAll = 1
}

public let MaximumLengthInBytesForMemoText = 28
public let QRCodeSeparationString = " "
public let QRCodeNativeCurrencyIssuer = "native"
public let OtherCurrencyText = "Other"

class SendViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, WalletActionsProtocol, ScanViewControllerDelegate, UITextFieldDelegate {
    @IBOutlet weak var currentCurrencyLabel: UILabel!
    @IBOutlet weak var addressErrorLabel: UILabel!
    @IBOutlet weak var amountErrorLabel: UILabel!
    @IBOutlet weak var memoInputErrorLabel: UILabel!
    @IBOutlet weak var sendErrorLabel: UILabel!
    @IBOutlet weak var availableAmountLabel: UILabel!
    @IBOutlet weak var sendAllCurrency: UILabel!
    @IBOutlet weak var sendAllValue: UILabel!
    @IBOutlet weak var otherCurrencyErrorLabel: UILabel!
    @IBOutlet weak var transactionFeeLabel: UILabel!
    
    @IBOutlet weak var memoTypeTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var memoInputTextField: UITextField!
    @IBOutlet weak var issuerTextField: UITextField!
    @IBOutlet weak var currentCurrencyTextField: UITextField!
    @IBOutlet weak var otherCurrencyTextField: UITextField!
    
    @IBOutlet weak var addressErrorView: UIView!
    @IBOutlet weak var amountErrorView: UIView!
    @IBOutlet weak var sendErrorView: UIView!
    @IBOutlet weak var memoInputErrorView: UIView!
    @IBOutlet weak var issuerView: UIView!
    @IBOutlet weak var contentView: UIScrollView!
    @IBOutlet weak var sendAllView: UIView!
    @IBOutlet weak var sendAmountView: UIView!
    @IBOutlet weak var availableAmountView: UIView!
    @IBOutlet weak var otherCurrencyView: UIView!
    @IBOutlet weak var otherCurrencyErrorView: UIView!
    @IBOutlet weak var passwordViewContainer: UIView!
    
    @IBOutlet weak var sendButton: UIButton!
    
    @IBOutlet weak var amountSegmentedControl: UISegmentedControl!
    
    private var currencyPickerView: UIPickerView!
    private var issuerPickerView: UIPickerView!
    private var memoTypePickerView: UIPickerView!
    
    private var isInputDataValid: Bool = true
    private var createRecepientAccount = false
    private var userMnemonic: String!
    private var availableAmount: CoinUnit?
    private var otherCurrencyAsset: AccountBalanceResponse?
    
    private var scanViewController: ScanViewController!
    private let userManager = UserManager()
    private let passwordManager = PasswordManager()
    
    var wallet: Wallet!
    var closeAction: (() -> ())?
    var sendAction: ((TransactionInput) -> ())?
    
    private var memoTypes: [MemoTypeValues] = [MemoTypeValues.MEMO_TEXT, MemoTypeValues.MEMO_ID, MemoTypeValues.MEMO_HASH, MemoTypeValues.MEMO_RETURN]
    private var passwordView: PasswordView!
    
    @IBAction func amountSegmentedControlValueChanged(_ sender: UISegmentedControl) {
        if amountSegmentedControl.selectedSegmentIndex == AmountSegmentedControlIndexes.sendAmount.rawValue {
            sendAmountView.isHidden = false
            sendAllView.isHidden = true
            availableAmount = nil
        } else if amountSegmentedControl.selectedSegmentIndex == AmountSegmentedControlIndexes.sendAll.rawValue{
            sendAmountView.isHidden = true
            sendAllView.isHidden = false
            amountErrorView.isHidden = true
            setAvailableAmount()
        }
    }
    
    @IBAction func sendButtonAction(_ sender: UIButton) {
        sendActionPreparation()
    }

    private func sendActionPreparation(biometricAuth: Bool = false) {
        resetValidations()
        sendButton.setTitle(SendButtonTitles.validating.rawValue, for: UIControlState.normal)
        sendButton.isEnabled = false
        if validateInsertedData(biometricAuth: biometricAuth) {
            if passwordView.passwordStackView.isHidden {
                validateInput(forMasterKey: false, biometricAuth: false)
            } else {
                validateInput(forMasterKey: true, biometricAuth: biometricAuth)
            }
        }
        else {
            resetSendButtonToNormal()
        }
    }
    
    private func validateInput(forMasterKey: Bool, biometricAuth: Bool) {
        if let address = addressTextField.text {
            var accountId = address
            
            // resolve federation if needed
            if address.isFederationAddress() {
                
                let parts = address.components(separatedBy: "*")
                let federationServer = "https://" + parts[1]
                let federation = Federation(federationAddress: federationServer)
                
                federation.resolve(address: address) { (response) -> (Void) in
                    switch response {
                    case .success(let federationResponse):
                        if let pk = federationResponse.accountId {
                            accountId = pk
                        } else {
                            self.setValidationError(view: self.addressErrorView, label: self.addressErrorLabel, errorMessage: .FederationNotFound)
                        }
                    case .failure(_):
                        self.setValidationError(view: self.addressErrorView, label: self.addressErrorLabel, errorMessage: .FederationNotFound)
                    }
                }
            }
            
            if (!isInputDataValid) { // could not resolve federation addres
                return
            }
            
            let password = !biometricAuth ? passwordView.passwordTextField.text : nil
            
            if otherCurrencyView.isHidden { // currency is native or selected from dropdown
                if let currency = getSelectedCurrency() {
                    validateDestination(accountId: accountId, currency: currency)
                } else {
                    self.setValidationError(view: self.sendErrorView, label: self.sendErrorLabel, errorMessage: .CurrencyNotFound)
                }
                
                if (isInputDataValid && forMasterKey) {
                    validatePasswordAndSendPaymentIfValid(password: password)
                } else {
                    sendPaymentIfValid()
                }
                
            } else { // currency asset code is provided by user, current account is issuer
                userManager.hasAccountTrustline(forAccount: accountId, forAssetCode: selectedCurrency, forAssetIssuer: wallet.publicKey) { (response) -> (Void) in
                    switch (response) {
                    case .success(hasTrustline: let hasTrustline, currency: let currencyResponse):
                        let currency = currencyResponse
                        if (hasTrustline) {
                            self.otherCurrencyAsset = currency
                            if (forMasterKey) {
                                self.validatePasswordAndSendPaymentIfValid(password: password)
                            } else {
                                self.sendPaymentIfValid()
                            }
                        } else {
                            self.setValidationError(view: self.otherCurrencyErrorView, label: self.otherCurrencyErrorLabel, errorMessage: .CurrencyNoTrust)
                            self.setSendButtonDefaultTitle()
                        }
                    case .failure(error: let error):
                        print("error looking up for trustline of recepient account: \(error)")
                        self.setValidationError(view: self.sendErrorView, label: self.sendErrorLabel, errorMessage: .ResolveRecepientAddress)
                    }
                }
            }
        }
    }
    
    private func validateDestination(accountId: String, currency:AccountBalanceResponse) {
        self.userManager.checkAddressStatus(forAccountID: accountId, asset: currency, completion: { (addressResult) -> (Void) in
            switch addressResult {
            case .success(isFunded: let isFunded, isTrusted: let isTrusted):
                if !isFunded {
                    self.createRecepientAccount = true
                } else if let isTrusted = isTrusted, !isTrusted {
                    self.setValidationError(view: self.addressErrorView, label: self.addressErrorLabel, errorMessage: .CurrencyNoTrust)
                }
            case .failure: // TODO: handle: address found but horizon error
                self.setValidationError(view: self.addressErrorView, label: self.addressErrorLabel, errorMessage: .ResolveRecepientAddress)
            }
        })
    }
    
    private func validatePasswordAndSendPaymentIfValid(password: String?) {
        passwordManager.getMnemonic(password: password) { (passwordResult) -> (Void) in
            switch passwordResult {
            case .success(mnemonic: let mnemonic):
                self.userMnemonic = mnemonic
                self.sendPaymentIfValid()
            case .failure(error: let error):
                print("Error: \(error)")
                self.passwordView.showInvalidPasswordError()
            }
        }
    }
    
    private func getSelectedCurrency() -> AccountBalanceResponse? {
        return (wallet as! FundedWallet).balances.first(where: { (currency) -> Bool in
            if selectedCurrency == NativeCurrencyNames.xlm.rawValue {
                return currency.displayCode == selectedCurrency
            }
            
            return currency.displayCode == selectedCurrency && currency.assetIssuer == issuerTextField.text})
    }
    
    private func sendPaymentIfValid() {
        if isInputDataValid {
            sendPayment()
        } else {
            resetSendButtonToNormal()
        }
    }
    
    @objc func addressChanged(_ textField: UITextField) {
        if createRecepientAccount {
            setSendButtonDefaultTitle()
            createRecepientAccount = false
        }
    }
    
    @objc func otherCurrencyChanged(_ textField: UITextField) {
        selectedCurrency = otherCurrencyTextField.text ?? ""
        currentCurrencyLabel.text = selectedCurrency
        setSendButtonDefaultTitle()
        validateAssetCode()
    }
    
    private var selectedMemoType: MemoTypeValues! = MemoTypeValues.MEMO_TEXT {
        didSet {
            memoTypeTextField.text = selectedMemoType.rawValue
            
            switch selectedMemoType.rawValue {
            case MemoTypeValues.MEMO_TEXT.rawValue:
                memoInputTextField.placeholder = MemoTextFieldPlaceholders.MemoText.rawValue
                memoInputTextField.keyboardType = .default
    
            case MemoTypeValues.MEMO_ID.rawValue:
                memoInputTextField.placeholder = MemoTextFieldPlaceholders.MemoID.rawValue
                memoInputTextField.keyboardType = .numberPad

            case MemoTypeValues.MEMO_HASH.rawValue:
                memoInputTextField.placeholder = MemoTextFieldPlaceholders.MemoReturn.rawValue
                memoInputTextField.keyboardType = .default
                
            case MemoTypeValues.MEMO_RETURN.rawValue:
                memoInputTextField.placeholder = MemoTextFieldPlaceholders.MemoReturn.rawValue
                memoInputTextField.keyboardType = .default
                
            default:
                break
            }
        }
    }
    
    private var selectedCurrency: String = "" {
        didSet {
            if !otherCurrencyView.isHidden {
                return
            }
            
            currentCurrencyLabel.text = selectedCurrency
            
            let currencyIssuer = (wallet as! FundedWallet).balances.first { (currency) -> Bool in
                return currency.assetCode == selectedCurrency
            }?.assetIssuer
            
            if selectedCurrency == NativeCurrencyNames.xlm.rawValue {
                currentCurrencyTextField.text = nil
                currentCurrencyTextField.insertText(NativeCurrencyNames.stellarLumens.rawValue)
            } else {
                currentCurrencyTextField.text = nil
                currentCurrencyTextField.insertText(selectedCurrency)
            }
            
            setSendButtonDefaultTitle()
            
            if (wallet as! FundedWallet).isCurrencyDuplicateAndValid(withAssetCode: selectedCurrency) {
                if issuerPickerView == nil {
                    issuerPickerView = UIPickerView()
                    issuerPickerView.delegate = self
                    issuerPickerView.dataSource = self
                    issuerTextField.inputView = issuerPickerView
                    issuerTextField.keyboardToolbar.doneBarButton.setTarget(self, action: #selector(issuerDoneButtonTap))
                }
                
                issuerView.isHidden = false
            } else {
                issuerView.isHidden = true
            }
            
            if let currencyIssuer = currencyIssuer {
                issuerTextField.text = nil
                issuerTextField.insertText(currencyIssuer)
            }
            
            setAvailableAmount()
        }
    }
    
    private func showQRScanner() {
        scanViewController = ScanViewController()
        scanViewController.delegate = self
        navigationController?.pushViewController(scanViewController, animated: true)
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationItem()
        setupMemoTypePicker()
        addressTextField.addTarget(self, action: #selector(addressChanged), for: .editingChanged)
        view.backgroundColor = Stylesheet.color(.veryLightGray)
        sendButton.backgroundColor = Stylesheet.color(.blue)
        transactionFeeLabel.text = "Stellar transaction fee: \(String(format: "%.5f", CoinUnit.Constants.transactionFee)) XLM"
        setupPasswordView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        availableCurrencies = (wallet as! FundedWallet).getAvailableCurrencies()
        if selectedCurrency.isEmpty {
            selectedCurrency = availableCurrencies.first!
        }
        
        checkForTransactionFeeAvailability()
        resetSendButtonToNormal()
    }
    
    private func setupPasswordView() {
        if let wallet = wallet as? FundedWallet {
            passwordView = Bundle.main.loadNibNamed("PasswordView", owner: self, options: nil)![0] as? PasswordView
            passwordView.neededSigningSecurity = .medium
            passwordView.wallet = wallet
            passwordView.contentView = contentView
            
            passwordView.biometricAuthAction = {
                self.sendActionPreparation(biometricAuth: true)
            }
            
            passwordViewContainer.addSubview(passwordView)
            
            passwordView.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
        }
    }
    
    private func setupForOtherCurrency() {
        currentCurrencyTextField.text = nil
        currentCurrencyTextField.insertText(OtherCurrencyText)
        availableAmountView.isHidden = true
        otherCurrencyView.isHidden = false
        amountSegmentedControl.selectedSegmentIndex = AmountSegmentedControlIndexes.sendAmount.rawValue
        sendAmountView.isHidden = false
        sendAllView.isHidden = true
        availableAmount = nil
        amountSegmentedControl.isEnabled = false
        
        selectedCurrency = ""
        currentCurrencyLabel.text = selectedCurrency
        setSendButtonDefaultTitle()
        
        otherCurrencyTextField.addTarget(self, action: #selector(otherCurrencyChanged), for: .editingChanged)
    }
    
    private func setupForSelectedCurrency() {
        if !otherCurrencyView.isHidden {
            otherCurrencyAsset = nil
            availableAmountView.isHidden = false
            otherCurrencyView.isHidden = true
            amountSegmentedControl.isEnabled = true
            resetOtherCurrencyValidationError()
            otherCurrencyTextField.text = nil
            otherCurrencyTextField.removeTarget(self, action: #selector(otherCurrencyChanged), for: .editingChanged)
        }
    }
    
    private func setupMemoTypePicker() {
        memoTypePickerView = UIPickerView()
        memoTypePickerView.delegate = self
        memoTypePickerView.dataSource = self
        memoTypeTextField.text = selectedMemoType.rawValue
        memoTypeTextField.inputView = memoTypePickerView
        memoTypeTextField.keyboardToolbar.doneBarButton.setTarget(self, action: #selector(memoTypeDoneButtonTap))
    }
    
    private func setAvailableLabels(currency: AccountBalanceResponse) {
        if let balance = CoinUnit(currency.balance) {
            let availableAmount = currency.assetCode != nil ? balance : balance.availableAmount(forWallet: wallet, forCurrency: currency)
            availableAmountLabel.text = "You have \(availableAmount) \(selectedCurrency) available"
            
            if amountSegmentedControl.selectedSegmentIndex == AmountSegmentedControlIndexes.sendAll.rawValue {
                setSendAllLabel(amount: availableAmount)
            }
        }
    }
    
    private func setAvailableAmount() {
        for currency in (wallet as! FundedWallet).uniqueAssetCodeBalances {
            if selectedCurrency == NativeCurrencyNames.xlm.rawValue {
                setAvailableLabels(currency: currency)
            } else if let currencyIssuer = issuerTextField.text,
                currency.assetIssuer == currencyIssuer,
                currency.assetCode == selectedCurrency {
                setAvailableLabels(currency: currency)
            }
        }
    }
    
    private var availableCurrencies: [String] = [""] {
        didSet {
            currencyPickerView = UIPickerView()
            currencyPickerView.delegate = self
            currencyPickerView.dataSource = self
            currentCurrencyTextField.inputView = currencyPickerView
            currentCurrencyTextField.keyboardToolbar.doneBarButton.setTarget(self, action: #selector(currencyDoneButtonTap))
            availableCurrencies.append(OtherCurrencyText)
        }
    }
    
    private func setSendAllLabel(amount: CoinUnit) {
        sendAllValue.text = "\(amount)"
        sendAllCurrency.text = selectedCurrency
        availableAmount = amount
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
                                               amount: availableAmount != nil ? String(availableAmount!) : (self.amountTextField.text ?? ""),
                                               memo: self.memoInputTextField.text?.isEmpty == false ? self.memoInputTextField.text! : nil,
                                               memoType: self.memoTypes.first(where: { (memoType) -> Bool in
                                                if let memoTypeTextFieldValue = self.memoTypeTextField.text {
                                                    return memoType.rawValue == memoTypeTextFieldValue
                                                }
                                                
                                                return memoType.rawValue == MemoTypeValues.MEMO_TEXT.rawValue
                                               }),
                                               userMnemonic: self.userMnemonic,
                                               transactionType: self.createRecepientAccount ? TransactionActionType.createAndFundAccount : TransactionActionType.sendPayment,
                                               signer: self.passwordView.useExternalSigning ? self.passwordView.signersTextField.text : nil,
                                               signerSeed: self.passwordView.useExternalSigning ? self.passwordView.seedTextField.text : nil,
                                               otherCurrencyAsset: self.otherCurrencyAsset ?? nil)
        self.clearSeedAndPasswordFields()
        self.sendAction?(transactionData)
    }
    
    private func clearSeedAndPasswordFields() {
        passwordView.seedTextField = nil
        passwordView.passwordTextField = nil
    }
    
    private func getSendButtonDefaultTitle() -> String {
        return "SEND \(selectedCurrency)"
    }
    
    private func setSendButtonDefaultTitle() {
        let sendButtonTitle: String = getSendButtonDefaultTitle()
        sendButton.setTitle(sendButtonTitle, for: .normal)
        
        if !sendButton.isEnabled {
            sendButton.isEnabled = true
        }
    }
    
    private func checkForTransactionFeeAvailability() {
        if (wallet as! FundedWallet).nativeBalance.availableAmount(forWallet: wallet, forCurrency: (wallet as? FundedWallet)?.nativeAsset).isLess(than: CoinUnit.minimumAccountBalance(forWallet: wallet)) {
            sendErrorView.isHidden = false
            sendErrorLabel.text = ValidationErrors.InsufficientLumens.rawValue
            sendButton.isEnabled = false
        }
    }
    
    private func resetValidations() {
        addressErrorView.isHidden = true
        addressErrorLabel.text = nil
        amountErrorView.isHidden = true
        amountErrorLabel.text = nil
        memoInputErrorView.isHidden = true
        memoInputErrorLabel.text = nil
        sendErrorView.isHidden = true
        sendErrorLabel.text = nil
        otherCurrencyErrorView.isHidden = true
        otherCurrencyErrorLabel.text = nil
        isInputDataValid = true
        passwordView.resetValidationErrors()
        setSendButtonDefaultTitle()
    }
    
    private func setValidationError(view: UIView, label: UILabel, errorMessage: ValidationErrors) {
        view.isHidden = false
        label.text = errorMessage.rawValue
        isInputDataValid = false
        
        contentView.setContentOffset(CGPoint(x: 0, y: view.frame.center.y), animated: false)
    }
    
    private func resetOtherCurrencyValidationError() {
        otherCurrencyAsset = nil
        otherCurrencyErrorLabel.text = nil
        otherCurrencyErrorView.isHidden = true
        isInputDataValid = true
    }
    
    private func validateAssetCodeIsFilled() {
        if !otherCurrencyView.isHidden, let assetCode = otherCurrencyTextField.text, !assetCode.isMandatoryValid() {
            setValidationError(view: otherCurrencyErrorView, label: otherCurrencyErrorLabel, errorMessage: .Mandatory)
        }
    }
    
    private func validateAssetCode() {
        if let assetCode = otherCurrencyTextField.text {
            if !assetCode.isAssetCodeValid() {
                setValidationError(view: otherCurrencyErrorView, label: otherCurrencyErrorLabel, errorMessage: .InvalidAssetCode)
            } else {
                resetOtherCurrencyValidationError()
            }
        }
    }
    
    private func validateAddress() {
        if let address = addressTextField.text {
            if !address.isMandatoryValid() {
                setValidationError(view: addressErrorView, label: addressErrorLabel, errorMessage: .Mandatory)
                return
            }
            
            if address.isFederationAddress() {
                return
            }
            
            if !address.isBase64Valid() || !address.isPublicKey(){
                setValidationError(view: addressErrorView, label: addressErrorLabel, errorMessage: .InvalidAddress)
            }
        }
    }
    
    private func validateAmount() {
        if let amountToValidate = self.amountTextField.text, availableAmount == nil {
            if !amountToValidate.isMandatoryValid() {
                setValidationError(view: amountErrorView, label: amountErrorLabel, errorMessage: .Mandatory)
                return
            }
            
            validate(amount: amountToValidate)
        } else if let amountToValidate = availableAmount {
            validate(amount: String(amountToValidate))
        }
    }
    
    private func validate(amount: String) {
        if !amount.isNumeric() {
            setValidationError(view: amountErrorView, label: amountErrorLabel, errorMessage: .InvalidAmount)
            return
        }
        
        if let balance: String = (wallet as! FundedWallet).balances.first(where: { (balance) -> Bool in
            if selectedCurrency == NativeCurrencyNames.xlm.rawValue {
                return balance.displayCode == selectedCurrency
            }
            
            return balance.displayCode == selectedCurrency && balance.assetIssuer == issuerTextField.text})?.balance {
            
            var balanceToValidate = balance
            
            if selectedCurrency == NativeCurrencyNames.xlm.rawValue {
                if let balance = CoinUnit(balance) {
                    balanceToValidate = String(balance.availableAmount(forWallet: wallet, forCurrency: (wallet as? FundedWallet)?.nativeAsset))
                }
            }
            
            if !amount.isAmountValid(forBalance: balanceToValidate) {
                amountErrorView.isHidden = false
                amountErrorLabel.text = "Insufficient \(selectedCurrency) available"
                isInputDataValid = false
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
                    setValidationError(view: memoInputErrorView, label: memoInputErrorLabel, errorMessage: .InvalidMemo)
                    return
                }
                
                if memoTextValidationResult == MemoTextValidationResult.InvalidLength {
                    setValidationError(view: memoInputErrorView, label: memoInputErrorLabel, errorMessage: .MemoLength)
                    return
                }
                
            case MemoTypeValues.MEMO_ID.rawValue:
                if !memoText.isMemoIDValid() {
                    setValidationError(view: memoInputErrorView, label: memoInputErrorLabel, errorMessage: .InvalidMemo)
                }
                
            case MemoTypeValues.MEMO_HASH.rawValue:
                if !memoText.isMemoHashValid() {
                    setValidationError(view: memoInputErrorView, label: memoInputErrorLabel, errorMessage: .InvalidMemo)
                }
                
            case MemoTypeValues.MEMO_RETURN.rawValue:
                if !memoText.isMemoReturnValid() {
                    setValidationError(view: memoInputErrorView, label: memoInputErrorLabel, errorMessage: .InvalidMemo)
                }
                
            default:
                break
            }
        }
    }
    
    private func validateInsertedData(biometricAuth: Bool = false) -> Bool {
        validateAddress()
        validateAssetCodeIsFilled()
        validateAmount()
        validateMemo()
        if isInputDataValid {
            isInputDataValid = passwordView.validatePassword(biometricAuth: biometricAuth)
        }
        
        checkForTransactionFeeAvailability()
        //checkForRecipientAccount()
        
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
        
        currentCurrencyTextField.text = nil
        currentCurrencyTextField.insertText(qrResultArray[0])
        issuerTextField.text = qrResultArray[1] != QRCodeNativeCurrencyIssuer ? qrResultArray[1] : nil
        addressTextField.text = qrResultArray[2]
        amountTextField.text = qrResultArray[3]
        
        switch qrResultArray[4] {
        case MemoTypeAsString.TEXT:
            memoTypeTextField.text = MemoTypeValues.MEMO_TEXT.rawValue
        case MemoTypeAsString.ID:
            memoTypeTextField.text = MemoTypeValues.MEMO_ID.rawValue
        case MemoTypeAsString.HASH:
            memoTypeTextField.text = MemoTypeValues.MEMO_HASH.rawValue
        case MemoTypeAsString.RETURN:
            memoTypeTextField.text = MemoTypeValues.MEMO_RETURN.rawValue
        default:
            break
        }
        
        if qrResultArray[5] != MemoTypeAsString.NONE {
            memoInputTextField.text = qrResultArray[5]
        }
        
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
            return (wallet as! FundedWallet).issuersFor(assetCode: selectedCurrency).count
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
            return (wallet as! FundedWallet).issuersFor(assetCode: selectedCurrency)[row]
        }
        
        return nil
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectAsset(pickerView: pickerView, row: row)
    }
    
    @IBAction func didTapScan(_ sender: Any) {
        showQRScanner()
    }
    
    private func selectAsset(pickerView: UIPickerView, row: Int) {
        if pickerView == currencyPickerView {
            if availableCurrencies[row] == OtherCurrencyText {
                setupForOtherCurrency()
                return
            }
        
        setupForSelectedCurrency()
        selectedCurrency = availableCurrencies[row]
        return
        } else if pickerView == memoTypePickerView {
            selectedMemoType = memoTypes[row]
            return
        } else if pickerView == issuerPickerView {
            issuerTextField.text = (wallet as! FundedWallet).issuersFor(assetCode: selectedCurrency)[row]
            return
        }
    }
    
    private func resetSendButtonToNormal() {
        sendButton.setTitle(getSendButtonDefaultTitle(), for: UIControlState.normal)
        sendButton.isEnabled = true
    }
    
    private func setupNavigationItem() {
        navigationItem.titleLabel.text = "Send"
        navigationItem.titleLabel.textColor = Stylesheet.color(.white)
        navigationItem.titleLabel.font = R.font.encodeSansSemiBold(size: 15)
        
        let scanQrButton = Material.IconButton()
        scanQrButton.image = R.image.qr_placeholder()?.crop(toWidth: 25, toHeight: 25)?.tint(with: Stylesheet.color(.white))
        scanQrButton.addTarget(self, action: #selector(didTapScan(_:)), for: .touchUpInside)
        navigationItem.rightViews = [scanQrButton]
    }
}
