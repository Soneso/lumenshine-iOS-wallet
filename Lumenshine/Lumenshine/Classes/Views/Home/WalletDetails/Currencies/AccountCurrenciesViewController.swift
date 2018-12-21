//
//  AccountCurrenciesViewController.swift
//  Lumenshine
//
//  Created by Soneso GmbH on 12/12/2018.
//  Munich, Germany
//  web: https://soneso.com
//  email: hi@soneso.com
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import stellarsdk

class IntrinsicView: UIView {
    var desiredHeight: CGFloat = 0
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: frame.width, height: desiredHeight)
    }
}

class AccountCurrenciesViewController: UIViewController {
    @IBOutlet weak var currenciesStackView: UIStackView!
    @IBOutlet weak var loadingCurrenciesStackView: UIStackView!
    @IBOutlet weak var intrinsicView: IntrinsicView!
    
    var wallet: FundedWallet!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCurrencies()
    }

    @IBAction func didTapAddCurrency(_ sender: Any) {
        let addCurrencyViewController = AddCurrencyViewController(nibName: "AddCurrencyViewController", bundle: Bundle.main)
        addCurrencyViewController.wallet = wallet
        navigationController?.pushViewController(addCurrencyViewController, animated: true)
    }
    
    private func setupCurrencies() {

        var currencyViewHeight: CGFloat = 0
        for balance in self.wallet.balances {
            if let newAssetCode = balance.assetCode, let newIssuer = balance.assetIssuer{
                var alreadyExists = false
                for arrangedSubView in self.currenciesStackView.arrangedSubviews {
                    if let existingCurrencyView = arrangedSubView as? CurrencyView, newAssetCode == existingCurrencyView.assetCode, newIssuer == existingCurrencyView.issuerPK {
                            alreadyExists = true
                            break
                    }
                }
                if alreadyExists {
                    continue
                }
                let currencyView = Bundle.main.loadNibNamed("CurrencyView", owner:self, options:nil)![0] as! CurrencyView
                
                // TODO : add server method to check this.
                balance.authorized = true
                currencyView.currency = balance
                
                currencyView.removeAction = { [weak balance, weak self] (tappedCurrency) in
                    if tappedCurrency == balance {
                        self?.removeCurrency(forCurrency: tappedCurrency)
                    }
                }
                
                currencyView.detailsAction = { [weak balance, weak self] (tappedCurrency) in
                    if tappedCurrency == balance {
                        self?.showCurrencyDetails(forCurrency: tappedCurrency)
                    }
                }
                
                if currencyViewHeight == 0 {
                    currencyViewHeight = currencyView.frame.height
                }
                
                self.currenciesStackView.addArrangedSubview(currencyView)
            }
        }
        
        self.calculateAndSetContentSize(nrOfCurrencies: self.wallet.balances.count, viewHeight: currencyViewHeight)
    }
    
    private func activityIndicator(showLoading: Bool) {
        self.loadingCurrenciesStackView.isHidden = !showLoading
    }
    
    private func calculateAndSetContentSize(nrOfCurrencies: Int, viewHeight: CGFloat) {
        intrinsicView.desiredHeight = CGFloat(nrOfCurrencies) * viewHeight + CGFloat(10 * nrOfCurrencies)
        intrinsicView.invalidateIntrinsicContentSize()
    }
    
    private func showCurrencyDetails(forCurrency currency: AccountBalanceResponse) {
        
        let detailsVC = CurrencyDetailsViewController()
        detailsVC.modalTitle = "Currency details"
        detailsVC.assetCode = currency.assetCode
        detailsVC.assetIssuerPk = currency.assetIssuer
        detailsVC.limit = currency.limit
        
        if let assetIssuer = currency.assetIssuer {
            showActivity(message: R.string.localizable.loading())
            
            Services.shared.walletService.getAccountDetails(accountId: assetIssuer) { (response) -> (Void) in
                switch response {
                case .success(let accountResponse):
                    if let homeDomain = accountResponse.homeDomain {
                        detailsVC.homeDomain = homeDomain
                        do {
                            try StellarToml.from(domain: homeDomain, secure: true) { (result) -> (Void) in
                                switch result {
                                case .success(response: let stellarToml):
                                    
                                    //Alternately, stellar.toml can link out to a separate TOML file for each currency by specifying toml="https://DOMAIN/.well-known/CURRENCY.toml" as the currency's only field.
                                    if let linkedCurrencyDocumentation = self.linkedCurrencyDocumentation(stellarToml: stellarToml, assetCode: currency.assetCode, assetIssuer: currency.assetIssuer) {
                                        stellarToml.currenciesDocumentation.append(linkedCurrencyDocumentation)
                                    }
                                    
                                    detailsVC.stellarToml = stellarToml
                                    detailsVC.organisationLogo = self.organisationLogo(stellarToml: stellarToml)
                                    detailsVC.currencyImage = self.currencyLogo(stellarToml: stellarToml, assetCode: currency.assetCode, assetIssuer: currency.assetIssuer)
                                    
                                case .failure(error: let stellarTomlError):
                                    switch stellarTomlError {
                                    case .invalidDomain:
                                        detailsVC.invalidTomlDomain = true
                                    case .invalidToml:
                                        detailsVC.invalidToml = true
                                    }
                                }
                                self.showDetailsController(detailsVC: detailsVC)
                            }
                        } catch {
                            detailsVC.invalidToml = true
                            self.showDetailsController(detailsVC: detailsVC)
                        }
                    } else {
                        self.showDetailsController(detailsVC: detailsVC)
                    }
                case .failure(let error):
                    StellarSDKLog.printHorizonRequestErrorMessage(tag:"Error:", horizonRequestError: error)
                    DispatchQueue.main.async {
                        self.hideActivity(completion: {
                            self.displaySimpleAlertView(title: "Error", message: "Could not find issuer: \(assetIssuer)")
                        })
                    }
                }
            }
        } else {
            showDetailsController(detailsVC: detailsVC)
        }
    
    }
    
    func linkedCurrencyDocumentation(stellarToml: StellarToml, assetCode:String?, assetIssuer:String?) -> CurrencyDocumentation? {
        if let code = assetCode, let issuer = assetIssuer {
            var linkedTomlUrls: [URL] = []
            for currencyDoc in stellarToml.currenciesDocumentation {
                if currencyDoc.code == code, currencyDoc.issuer == issuer {
                    // toml already contains the needed documentation
                    return nil
                } else if let tomlLink = currencyDoc.toml, let tomlUrl = URL(string: tomlLink) {
                    linkedTomlUrls.append(tomlUrl)
                }
            }
            
            for nextUrl in linkedTomlUrls {
                if let tomlString = try? String(contentsOf: nextUrl, encoding: .utf8), let currencyToml = try? StellarToml(fromString: tomlString) {
                    for nextCurrencyDoc in currencyToml.currenciesDocumentation {
                        if nextCurrencyDoc.code == code, nextCurrencyDoc.issuer == issuer {
                            return nextCurrencyDoc
                        }
                    }
                }
            }
        }
        return nil
    }
    
    func organisationLogo(stellarToml: StellarToml) -> UIImage? {
        if let orglogoUrl = stellarToml.issuerDocumentation.orgLogo, let url = URL(string: orglogoUrl), let data = try? Data(contentsOf: url) {
            return prepareImageForDetails(sourceImage:UIImage(data: data), maxHeight:75.0)
        }
        return nil
    }
    
    func currencyLogo(stellarToml: StellarToml, assetCode: String?, assetIssuer: String?) -> UIImage? {
        // get lopgo of the currency
        if let code = assetCode, let issuer = assetIssuer {
            for currdoc in stellarToml.currenciesDocumentation {
                if currdoc.code == code && currdoc.issuer == issuer {
                    if let currencyImageUrl = currdoc.image, let url = URL(string: currencyImageUrl), let data = try? Data(contentsOf: url) {
                        return prepareImageForDetails(sourceImage:UIImage(data: data), maxHeight:75.0)
                    }
                }
            }
        }
        return nil
    }
    
    func prepareImageForDetails(sourceImage:UIImage?, maxHeight: CGFloat) -> UIImage? {
        
        if let originalImage = sourceImage, originalImage.size.height > maxHeight {
            
            let oldHeight = originalImage.size.height
            let scaleFactor = maxHeight / oldHeight
            
            let newHeight = oldHeight * scaleFactor
            let newWidth = originalImage.size.width * scaleFactor
            
            UIGraphicsBeginImageContext(CGSize(width:newWidth, height:newHeight))
            originalImage.draw(in: CGRect(x:0, y:0, width:newWidth, height:newHeight))
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return newImage
        } else {
            return sourceImage
        }
    }
    
    private func showDetailsController(detailsVC:CurrencyDetailsViewController) {
        DispatchQueue.main.async {
            let composeVC = ComposeNavigationController(rootViewController: detailsVC)
            self.hideActivity(completion: {
                self.present(composeVC, animated: true)
            })
        }
    }
    
    private func removeCurrency(forCurrency currency: AccountBalanceResponse) {
        if let balance = CoinUnit(currency.balance) {
            if balance != 0.0 {
                self.displaySimpleAlertView(title: R.string.localizable.balance_not_zero_title(), message: R.string.localizable.balance_not_zero_msg())
                return
            }
        } else {
            return
        }
        
        let removeCurrencyViewController = RemoveCurrencyViewController(nibName: "RemoveCurrencyViewController", bundle: Bundle.main)
        removeCurrencyViewController.currency = currency
        removeCurrencyViewController.wallet = wallet
        navigationController?.pushViewController(removeCurrencyViewController, animated: true)
    }
}
