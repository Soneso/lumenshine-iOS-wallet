//
//  CurrencyDetailsViewController.swift
//  Lumenshine
//
//  Created by Soneso GmbH on 20/12/2018.
//  Munich, Germany
//  web: https://soneso.com
//  email: hi@soneso.com
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation
import UIKit
import Material
import SwiftRichString
import stellarsdk

class CurrencyDetailsViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var textView: UITextView!
    public var modalTitle = "Currency details"
    public var assetCode: String?
    public var assetIssuerPk: String?
    public var limit:String?
    public var homeDomain: String?
    public var stellarToml: StellarToml?
    public var invalidTomlDomain: Bool = false
    public var invalidToml: Bool = false
    public var currencyImage: UIImage? = nil
    public var organisationLogo: UIImage? = nil
    
    public var linksDict = [String: [String]]()
    public var chapters = [String]()
    public var bolds = [String]()
    private var infoText = ""
    
    private let normalTextAttributes: [NSAttributedString.Key : Any] = [ NSAttributedString.Key.foregroundColor: Stylesheet.color(.lightBlack), NSAttributedString.Key.font: R.font.encodeSansRegular(size: 16) as Any ]
    
    @IBAction func closeButtonAction(sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationItem()
        setupView()
        setupText()
    }
    
    private func setupNavigationItem() {
        view.backgroundColor = Stylesheet.color(.veryLightGray)
        navigationItem.titleLabel.text = modalTitle
        navigationItem.titleLabel.textColor = Stylesheet.color(.blue)
        navigationItem.titleLabel.font = R.font.encodeSansSemiBold(size: 15)
        
        let backButton = Material.IconButton()
        backButton.image = Icon.close?.tint(with: Stylesheet.color(.gray))
        backButton.addTarget(self, action: #selector(closeButtonAction(sender:)), for: .touchUpInside)
        navigationItem.leftViews = [backButton]
    }
    
    private func setupView() {
        view.backgroundColor = Stylesheet.color(.veryLightGray)
        textView.tintColor = Stylesheet.color(.blue)
        textView.delegate = self
    }
    
    private func setupText() {
        
        let text = NSMutableAttributedString(string: infoText, attributes: normalTextAttributes)
        
        if let assetCode = self.assetCode, let issuerPk = self.assetIssuerPk {
            let chapter_font = R.font.encodeSansSemiBold(size: 17) ?? Stylesheet.font(.body)
            let prefix_font = R.font.encodeSansBold(size: 15) ?? Stylesheet.font(.body)
            let font = R.font.encodeSansRegular(size: 15) ?? Stylesheet.font(.body)
            
            let notAvailableValue = NSAttributedString(string: "not available ⚠️" + "\n",
                                                       attributes: [NSAttributedString.Key.font : font,
                                                                    NSAttributedString.Key.foregroundColor : Stylesheet.color(.red)])
            
            let invalidValue = NSAttributedString(string: "invalid value ⚠️" + "\n",
                                                  attributes: [NSAttributedString.Key.font : font,
                                                               NSAttributedString.Key.foregroundColor : Stylesheet.color(.red)])
            
            let simpleBreak = NSAttributedString(string: "\n", attributes: [NSAttributedString.Key.font : prefix_font, NSAttributedString.Key.foregroundColor : Stylesheet.color(.darkGray)])
            
            let checkmark = NSAttributedString(string: " ✔️ ")
            let warning = NSAttributedString(string: " ⚠️ ")
            //let nogo = NSAttributedString(string: " 🛑 ")
            
            var orgHost: String? = nil
            
            if let tlink = stellarToml?.issuerDocumentation.orgURL, let turl = URL(string: tlink), let thost = turl.host  {
                orgHost = thost
            }
            
            // asset code
            let assetCodePrefix = NSAttributedString(string: "Asset code: ",
                                                     attributes: [NSAttributedString.Key.font : prefix_font,
                                                                  NSAttributedString.Key.foregroundColor : Stylesheet.color(.darkGray)])
            
            let assetCodeValue = NSAttributedString(string: assetCode + "\n",
                                                    attributes: [NSAttributedString.Key.font : font,
                                                                 NSAttributedString.Key.foregroundColor : Stylesheet.color(.darkGray)])
            
            text.append(assetCodePrefix)
            text.append(assetCodeValue)
            
            // issuer public key
            let issuerPkPrefix = NSAttributedString(string: "Issuer public key: ",
                                                    attributes: [NSAttributedString.Key.font : prefix_font,
                                                                 NSAttributedString.Key.foregroundColor : Stylesheet.color(.darkGray)])
            
            let issuerPkValue = NSAttributedString(string: issuerPk + "\n",
                                                   attributes: [NSAttributedString.Key.font : font,
                                                                NSAttributedString.Key.foregroundColor : Stylesheet.color(.darkGray)])
            
            
            text.append(issuerPkPrefix)
            text.append(issuerPkValue)
            
            // limit
            if let limit = self.limit {
                let limitPrefix = NSAttributedString(string: "Your limit: ",
                                                     attributes: [NSAttributedString.Key.font : prefix_font,
                                                                  NSAttributedString.Key.foregroundColor : Stylesheet.color(.darkGray)])
                
                let limitValue = NSAttributedString(string: limit + "\n",
                                                    attributes: [NSAttributedString.Key.font : font,
                                                                 NSAttributedString.Key.foregroundColor : Stylesheet.color(.darkGray)])
                text.append(limitPrefix)
                text.append(limitValue)
            }
            
            // home domain
            let homeDomainPrefix = NSAttributedString(string: "Home domain: ",
                                                      attributes: [NSAttributedString.Key.font : prefix_font,
                                                                   NSAttributedString.Key.foregroundColor : Stylesheet.color(.darkGray)])
            
            text.append(homeDomainPrefix)
            
            if let homeDomain = self.homeDomain {
                
                let link = homeDomain.hasPrefix("http") ? homeDomain : "https://\(homeDomain)"
                let homeDomainValue =  NSAttributedString(string: homeDomain, attributes: [.font : font, .foregroundColor : Stylesheet.color(.blue), .link :  link])
                
                text.append(homeDomainValue)
            } else {
                let homeDomainValue =  NSAttributedString(string: "home domain is missing in the stellar network for this issuer account", attributes: [.font : font, .foregroundColor : Stylesheet.color(.red)])
                text.append(homeDomainValue)
            }
            
            if invalidTomlDomain {
                let validationValue = NSAttributedString(string: "\n\nVerification failed: issuer has invalid stellar toml file." + "\n",
                                                         attributes: [NSAttributedString.Key.font : font,
                                                                      NSAttributedString.Key.foregroundColor : Stylesheet.color(.red)])
                text.append(validationValue)
            } else if invalidTomlDomain {
                let validationValue = NSAttributedString(string: "\n\nVerification failed: issuer has no stellar toml file." + "\n",
                                                         attributes: [NSAttributedString.Key.font : font,
                                                                      NSAttributedString.Key.foregroundColor : Stylesheet.color(.red)])
                text.append(validationValue)
            } else if let stellarToml = self.stellarToml {
                
                // METADATA
                let metadataTitle = NSAttributedString(string: "\n\nCurrency metadata provided by issuer" + "\n\n", attributes: [NSAttributedString.Key.font : chapter_font,
                                                                                                                                 NSAttributedString.Key.foregroundColor : Stylesheet.color(.darkBlue)])
                text.append(metadataTitle)
                
                var metadataFound = false
                if stellarToml.currenciesDocumentation.count > 0 {
                    for currencyDoc in stellarToml.currenciesDocumentation {
                        //print("sac:\(self.assetCode)-\(currencyDoc.code)-sic:\(self.assetIssuerPk)-\(currencyDoc.issuer)")
                        if currencyDoc.code == self.assetCode && currencyDoc.issuer == self.assetIssuerPk {
                            metadataFound = true
                            
                            // currency status
                            let statusTitle = NSAttributedString(string: "Status: ", attributes: [NSAttributedString.Key.font : prefix_font,
                                                                                                  NSAttributedString.Key.foregroundColor : Stylesheet.color(.darkGray)])
                            text.append(statusTitle)
                            if let status = currencyDoc.status {
                                let statusValue = NSAttributedString(string: status + "\n",
                                                                     attributes: [NSAttributedString.Key.font : font,
                                                                                  NSAttributedString.Key.foregroundColor : Stylesheet.color(.darkGray)])
                                text.append(statusValue)
                            } else {
                                let statusValue = NSAttributedString(string: "status is missing",
                                                                     attributes: [NSAttributedString.Key.font : font,
                                                                                  NSAttributedString.Key.foregroundColor : Stylesheet.color(.red)])
                                text.append(statusValue)
                                text.append(warning)
                                text.append(simpleBreak)
                            }
                            
                            // short name
                            if let fname = currencyDoc.name {
                                let fnameTitle = NSAttributedString(string: "Short name: ", attributes: [NSAttributedString.Key.font : prefix_font,
                                                                                                         NSAttributedString.Key.foregroundColor : Stylesheet.color(.darkGray)])
                                text.append(fnameTitle)
                                let fnameValue = NSAttributedString(string: fname + "\n",
                                                                    attributes: [NSAttributedString.Key.font : font,
                                                                                 NSAttributedString.Key.foregroundColor : Stylesheet.color(.darkGray)])
                                text.append(fnameValue)
                            }
                            
                            // description
                            if let cdesc = currencyDoc.desc {
                                let cdescTitle = NSAttributedString(string: "Description: ", attributes: [NSAttributedString.Key.font : prefix_font,
                                                                                                          NSAttributedString.Key.foregroundColor : Stylesheet.color(.darkGray)])
                                text.append(cdescTitle)
                                let cdescValue = NSAttributedString(string: cdesc + "\n",
                                                                    attributes: [NSAttributedString.Key.font : font,
                                                                                 NSAttributedString.Key.foregroundColor : Stylesheet.color(.darkGray)])
                                text.append(cdescValue)
                            }
                            
                            // digits
                            if let digi = currencyDoc.displayDecimals {
                                let digiTitle = NSAttributedString(string: "Display digits: ", attributes: [NSAttributedString.Key.font : prefix_font,
                                                                                                            NSAttributedString.Key.foregroundColor : Stylesheet.color(.darkGray)])
                                text.append(digiTitle)
                                let digiValue = NSAttributedString(string: "\(digi)\n",
                                    attributes: [NSAttributedString.Key.font : font,
                                                 NSAttributedString.Key.foregroundColor : Stylesheet.color(.darkGray)])
                                text.append(digiValue)
                            }
                            
                            // conditions
                            if let condi = currencyDoc.conditions {
                                let condiTitle = NSAttributedString(string: "Conditions on token: ", attributes: [NSAttributedString.Key.font : prefix_font,
                                                                                                                  NSAttributedString.Key.foregroundColor : Stylesheet.color(.darkGray)])
                                text.append(condiTitle)
                                let condiValue = NSAttributedString(string: "\(condi)\n",
                                    attributes: [NSAttributedString.Key.font : font,
                                                 NSAttributedString.Key.foregroundColor : Stylesheet.color(.darkGray)])
                                text.append(condiValue)
                            }
                            
                            // image
                            if let cimage = self.currencyImage {
                                let cImageTitle = NSAttributedString(string: "Image:\n\n", attributes: [NSAttributedString.Key.font : prefix_font,
                                                                                                        NSAttributedString.Key.foregroundColor : Stylesheet.color(.darkGray)])
                                text.append(cImageTitle)
                                let imageAttachment = NSTextAttachment()
                                imageAttachment.image = cimage
                                let imageString = NSAttributedString(attachment: imageAttachment)
                                text.append(imageString)
                                text.append(simpleBreak)
                                text.append(simpleBreak)
                            }
                            
                            // fixed number of tokens
                            if let fixedNr = currencyDoc.fixedNumber {
                                let fixedNrTitle = NSAttributedString(string: "Fixed number of tokens: ", attributes: [NSAttributedString.Key.font : prefix_font, NSAttributedString.Key.foregroundColor : Stylesheet.color(.darkGray)])
                                text.append(fixedNrTitle)
                                let fixedNrValue = NSAttributedString(string: "\(fixedNr)\n",
                                    attributes: [NSAttributedString.Key.font : font,
                                                 NSAttributedString.Key.foregroundColor : Stylesheet.color(.darkGray)])
                                text.append(fixedNrValue)
                            }
                            
                            // max number of tokens
                            if let maxNr = currencyDoc.maxNumber {
                                let fixedNrTitle = NSAttributedString(string: "Max number of tokens: ", attributes: [NSAttributedString.Key.font : prefix_font, NSAttributedString.Key.foregroundColor : Stylesheet.color(.darkGray)])
                                text.append(fixedNrTitle)
                                let maxNrValue = NSAttributedString(string: "\(maxNr)\n",
                                    attributes: [NSAttributedString.Key.font : font,
                                                 NSAttributedString.Key.foregroundColor : Stylesheet.color(.darkGray)])
                                text.append(maxNrValue)
                            }
                            
                            // unlimited
                            if let unlimit = currencyDoc.isUnlimited {
                                let unlimitTitle = NSAttributedString(string: "Unlimited: ", attributes: [NSAttributedString.Key.font : prefix_font, NSAttributedString.Key.foregroundColor : Stylesheet.color(.darkGray)])
                                text.append(unlimitTitle)
                                let unlimitValue = NSAttributedString(string: "\(unlimit)\n",
                                    attributes: [NSAttributedString.Key.font : font,
                                                 NSAttributedString.Key.foregroundColor : Stylesheet.color(.darkGray)])
                                text.append(unlimitValue)
                            }
                            
                            // anchored
                            if let anchored = currencyDoc.isAssetAnchored {
                                let anchoredTitle = NSAttributedString(string: "Anchored: ", attributes: [NSAttributedString.Key.font : prefix_font, NSAttributedString.Key.foregroundColor : Stylesheet.color(.darkGray)])
                                text.append(anchoredTitle)
                                let anchoredValue = NSAttributedString(string: "\(anchored)\n",
                                    attributes: [NSAttributedString.Key.font : font,
                                                 NSAttributedString.Key.foregroundColor : Stylesheet.color(.darkGray)])
                                text.append(anchoredValue)
                            }
                            
                            // anchor asset type
                            if let anchorAssetType = currencyDoc.anchorAssetType {
                                let anchoredTitle = NSAttributedString(string: "Anchor asset type: ", attributes: [NSAttributedString.Key.font : prefix_font, NSAttributedString.Key.foregroundColor : Stylesheet.color(.darkGray)])
                                text.append(anchoredTitle)
                                let anchoredValue = NSAttributedString(string: "\(anchorAssetType)\n",
                                    attributes: [NSAttributedString.Key.font : font,
                                                 NSAttributedString.Key.foregroundColor : Stylesheet.color(.darkGray)])
                                text.append(anchoredValue)
                            }
                            
                            // anchor asset
                            if let anchorAsset = currencyDoc.anchorAsset {
                                let anchoredTitle = NSAttributedString(string: "Anchor asset: ", attributes: [NSAttributedString.Key.font : prefix_font, NSAttributedString.Key.foregroundColor : Stylesheet.color(.darkGray)])
                                text.append(anchoredTitle)
                                let anchoredValue = NSAttributedString(string: "\(anchorAsset)\n",
                                    attributes: [NSAttributedString.Key.font : font,
                                                 NSAttributedString.Key.foregroundColor : Stylesheet.color(.darkGray)])
                                text.append(anchoredValue)
                            }
                            
                            // redemption instructions
                            if let redemption = currencyDoc.redemptionInstructions {
                                let redTitle = NSAttributedString(string: "Redempotion instructions: ", attributes: [NSAttributedString.Key.font : prefix_font, NSAttributedString.Key.foregroundColor : Stylesheet.color(.darkGray)])
                                text.append(redTitle)
                                let redValue = NSAttributedString(string: "\(redemption)\n",
                                    attributes: [NSAttributedString.Key.font : font,
                                                 NSAttributedString.Key.foregroundColor : Stylesheet.color(.darkGray)])
                                text.append(redValue)
                            }
                            
                            // collateral addresses
                            if currencyDoc.collateralAddresses.count > 0 {
                                let colateralTitle = NSAttributedString(string: "Collateral addresses:\n", attributes: [NSAttributedString.Key.font : prefix_font, NSAttributedString.Key.foregroundColor : Stylesheet.color(.darkGray)])
                                text.append(colateralTitle)
                            }
                            for address in currencyDoc.collateralAddresses {
                                let colateralValue = NSAttributedString(string: address + "\n", attributes: [NSAttributedString.Key.font : font, NSAttributedString.Key.foregroundColor : Stylesheet.color(.darkGray)])
                                text.append(colateralValue)
                            }
                            
                            // collateral messages
                            if currencyDoc.collateralAddressMessages.count > 0 {
                                let colateralTitle = NSAttributedString(string: "Collateral address messages:\n", attributes: [NSAttributedString.Key.font : prefix_font, NSAttributedString.Key.foregroundColor : Stylesheet.color(.darkGray)])
                                text.append(colateralTitle)
                            }
                            for message in currencyDoc.collateralAddressMessages {
                                let colateralValue = NSAttributedString(string: message + "\n", attributes: [NSAttributedString.Key.font : font, NSAttributedString.Key.foregroundColor : Stylesheet.color(.darkGray)])
                                text.append(colateralValue)
                            }
                            
                            // collateral signatures
                            if currencyDoc.collateralAddressSignatures.count > 0 {
                                let colateralTitle = NSAttributedString(string: "Collateral address signatures:\n", attributes: [NSAttributedString.Key.font : prefix_font, NSAttributedString.Key.foregroundColor : Stylesheet.color(.darkGray)])
                                text.append(colateralTitle)
                            }
                            for signature in currencyDoc.collateralAddressSignatures {
                                let colateralValue = NSAttributedString(string: signature + "\n", attributes: [NSAttributedString.Key.font : font, NSAttributedString.Key.foregroundColor : Stylesheet.color(.darkGray)])
                                text.append(colateralValue)
                            }
                            
                            // regulated
                            var regulated = false
                            if let reg = currencyDoc.regulated {
                                regulated = reg
                            }
                            let regulatedTitle = NSAttributedString(string: "Asset is regulated: ", attributes: [NSAttributedString.Key.font : prefix_font, NSAttributedString.Key.foregroundColor : Stylesheet.color(.darkGray)])
                            text.append(regulatedTitle)
                            
                            let regulatedValue = NSAttributedString(string: "\(regulated)\n",
                                attributes: [NSAttributedString.Key.font : font,
                                             NSAttributedString.Key.foregroundColor : Stylesheet.color(.darkGray)])
                            text.append(regulatedValue)
                            
                            // approval server
                            if let approvalServer = currencyDoc.approvalServer {
                                let approvalTitle = NSAttributedString(string: "Approval server: ", attributes: [NSAttributedString.Key.font : prefix_font, NSAttributedString.Key.foregroundColor : Stylesheet.color(.darkGray)])
                                text.append(approvalTitle)
                                let approvalValue = NSAttributedString(string: "\(approvalServer)\n",
                                    attributes: [NSAttributedString.Key.font : font,
                                                 NSAttributedString.Key.foregroundColor : Stylesheet.color(.darkGray)])
                                text.append(approvalValue)
                            }
                            
                            // approval criteria
                            if let approvalCriteria = currencyDoc.approvalCriteria {
                                let approvalTitle = NSAttributedString(string: "Approval criteria: ", attributes: [NSAttributedString.Key.font : prefix_font, NSAttributedString.Key.foregroundColor : Stylesheet.color(.darkGray)])
                                text.append(approvalTitle)
                                let approvalValue = NSAttributedString(string: "\(approvalCriteria)\n",
                                    attributes: [NSAttributedString.Key.font : font,
                                                 NSAttributedString.Key.foregroundColor : Stylesheet.color(.darkGray)])
                                text.append(approvalValue)
                            }
                            
                            break
                        }
                    }
                }
                
                if !metadataFound {
                    text.append(notAvailableValue)
                }
                
                // ISSUER DOCUMENTATION
                let documentationTitle = NSAttributedString(string: "\n\nDocumentation" + "\n\n", attributes: [NSAttributedString.Key.font : chapter_font,
                                                                                                               NSAttributedString.Key.foregroundColor : Stylesheet.color(.darkBlue)])
                text.append(documentationTitle)
                
                // Organisation name
                let orgNameTitle = NSAttributedString(string: "Organisation name: ", attributes: [NSAttributedString.Key.font : prefix_font,
                                                                                                  NSAttributedString.Key.foregroundColor : Stylesheet.color(.darkGray)])
                text.append(orgNameTitle)
                
                if let name = stellarToml.issuerDocumentation.orgName {
                    let nameValue = NSAttributedString(string: name + "\n",
                                                       attributes: [NSAttributedString.Key.font : font,
                                                                    NSAttributedString.Key.foregroundColor : Stylesheet.color(.darkGray)])
                    text.append(nameValue)
                    
                } else {
                    text.append(notAvailableValue)
                }
                
                // Organisation dba
                if let dba = stellarToml.issuerDocumentation.orgDBA {
                    let orgDbaTitle = NSAttributedString(string: "Doing business as: ", attributes: [NSAttributedString.Key.font : prefix_font,
                                                                                                     NSAttributedString.Key.foregroundColor : Stylesheet.color(.darkGray)])
                    text.append(orgDbaTitle)
                    let dbaValue = NSAttributedString(string: dba + "\n",
                                                      attributes: [NSAttributedString.Key.font : font,
                                                                   NSAttributedString.Key.foregroundColor : Stylesheet.color(.darkGray)])
                    text.append(dbaValue)
                }
                
                // Organisation url
                let orgUrlTitle = NSAttributedString(string: "URL: ", attributes: [NSAttributedString.Key.font : prefix_font,
                                                                                   NSAttributedString.Key.foregroundColor : Stylesheet.color(.darkGray)])
                text.append(orgUrlTitle)
                
                if let orgUrl = stellarToml.issuerDocumentation.orgURL {
                    
                    if !orgUrl.hasPrefix("https://") {
                        text.append(invalidValue)
                    } else if let _ = URL(string:orgUrl) {
                        let orgUrlValue =  NSAttributedString(string: orgUrl, attributes: [.font : font, .foregroundColor : Stylesheet.color(.blue), .link :  link])
                        text.append(orgUrlValue)
                    } else {
                        text.append(invalidValue)
                    }
                    
                    text.append(simpleBreak)
                    
                } else {
                    text.append(notAvailableValue)
                }
                
                // Organisation logo
                if let logo = self.organisationLogo {
                    let logoTitle = NSAttributedString(string: "Logo:\n\n", attributes: [NSAttributedString.Key.font : prefix_font,
                                                                                         NSAttributedString.Key.foregroundColor : Stylesheet.color(.darkGray)])
                    text.append(logoTitle)
                    let logoAttachment = NSTextAttachment()
                    logoAttachment.image = logo
                    let logoString = NSAttributedString(attachment: logoAttachment)
                    text.append(logoString)
                    text.append(simpleBreak)
                    text.append(simpleBreak)
                }
                
                // Organisation description
                let orgDescTitle = NSAttributedString(string: "Description: ", attributes: [NSAttributedString.Key.font : prefix_font,
                                                                                            NSAttributedString.Key.foregroundColor : Stylesheet.color(.darkGray)])
                text.append(orgDescTitle)
                
                if let desc = stellarToml.issuerDocumentation.orgDescription {
                    let descValue = NSAttributedString(string: desc + "\n",
                                                       attributes: [NSAttributedString.Key.font : font,
                                                                    NSAttributedString.Key.foregroundColor : Stylesheet.color(.darkGray)])
                    text.append(descValue)
                    
                } else {
                    text.append(notAvailableValue)
                }
                
                // Organisation physical address
                let addressDescTitle = NSAttributedString(string: "Physical address: ",
                                                          attributes: [NSAttributedString.Key.font : prefix_font,
                                                                       NSAttributedString.Key.foregroundColor : Stylesheet.color(.darkGray)])
                
                text.append(addressDescTitle)
                
                if let address = stellarToml.issuerDocumentation.orgPhysicalAddress {
                    let addressValue = NSAttributedString(string: address + "\n",
                                                          attributes: [NSAttributedString.Key.font : font,
                                                                       NSAttributedString.Key.foregroundColor : Stylesheet.color(.darkGray)])
                    text.append(addressValue)
                    
                } else {
                    text.append(notAvailableValue)
                }
                
                // Organisation physical address atestation
                if let addressAtestation = stellarToml.issuerDocumentation.orgPhysicalAddressAttestation {
                    let aATitle = NSAttributedString(string: "Physical address atestation: ",
                                                     attributes: [NSAttributedString.Key.font : prefix_font,
                                                                  NSAttributedString.Key.foregroundColor : Stylesheet.color(.darkGray)])
                    text.append(aATitle)
                    
                    let aAValue =  NSAttributedString(string: addressAtestation, attributes: [.font : font, .foregroundColor : Stylesheet.color(.blue), .link : addressAtestation])
                    
                    if !addressAtestation.hasPrefix("https://") {
                        text.append(invalidValue)
                    } else if let url = URL(string: addressAtestation), let host = url.host, host == orgHost {
                        text.append(aAValue)
                    } else {
                        text.append(aAValue)
                        text.append(warning)
                    }
                    
                    text.append(simpleBreak)
                }
                
                // Organisation phone number
                let phoneDescTitle = NSAttributedString(string: "Phone number: ",
                                                        attributes: [NSAttributedString.Key.font : prefix_font,
                                                                     NSAttributedString.Key.foregroundColor : Stylesheet.color(.darkGray)])
                
                text.append(phoneDescTitle)
                
                if let phone = stellarToml.issuerDocumentation.orgPhoneNumber {
                    let link = phone.hasPrefix("tel://") ? phone : "tel://\(phone)"
                    let phoneValue =  NSAttributedString(string: phone, attributes: [.font : font, .foregroundColor : Stylesheet.color(.blue), .link :  link])
                    
                    text.append(phoneValue)
                    text.append(simpleBreak)
                    
                    // Organisation phone number atestation
                    if let phoneAtestation = stellarToml.issuerDocumentation.orgPhysicalAddressAttestation {
                        let pATitle = NSAttributedString(string: "Phone number atestation: ",
                                                         attributes: [NSAttributedString.Key.font : prefix_font,
                                                                      NSAttributedString.Key.foregroundColor : Stylesheet.color(.darkGray)])
                        text.append(pATitle)
                        
                        let pAValue =  NSAttributedString(string: phoneAtestation, attributes: [.font : font, .foregroundColor : Stylesheet.color(.blue), .link :  phoneAtestation])
                        
                        if !phoneAtestation.hasPrefix("https://") {
                            text.append(invalidValue)
                        } else if let url = URL(string: phoneAtestation), let host = url.host, host == orgHost {
                            text.append(pAValue)
                        } else {
                            text.append(pAValue)
                            text.append(warning)
                        }
                        
                        text.append(pAValue)
                        text.append(simpleBreak)
                    }
                    
                } else {
                    text.append(notAvailableValue)
                }
                
                // Organisation keybase
                if let keybase = stellarToml.issuerDocumentation.orgKeybase {
                    let keybaseTitle = NSAttributedString(string: "Keybase: ",
                                                          attributes: [NSAttributedString.Key.font : prefix_font,
                                                                       NSAttributedString.Key.foregroundColor : Stylesheet.color(.darkGray)])
                    text.append(keybaseTitle)
                    
                    let link = keybase.hasPrefix("https://keybase") ? keybase : "https://keybase.io/\(keybase)"
                    let keybaseValue =  NSAttributedString(string: keybase, attributes: [.font : font, .foregroundColor : Stylesheet.color(.blue), .link :  link])
                    
                    text.append(keybaseValue)
                    text.append(simpleBreak)
                }
                
                // Organisation twitter
                if let twitter = stellarToml.issuerDocumentation.orgTwitter {
                    let twitterTitle = NSAttributedString(string: "Twitter: ",
                                                          attributes: [NSAttributedString.Key.font : prefix_font,
                                                                       NSAttributedString.Key.foregroundColor : Stylesheet.color(.darkGray)])
                    text.append(twitterTitle)
                    
                    let link = twitter.hasPrefix("https://twitter") ? twitter : "https://twitter.com/\(twitter)"
                    let twitterValue =  NSAttributedString(string: twitter, attributes: [.font : font, .foregroundColor : Stylesheet.color(.blue), .link :  link])
                    
                    text.append(twitterValue)
                    text.append(simpleBreak)
                }
            
                // Organisation github
                if let github = stellarToml.issuerDocumentation.orgGithub{
                    let githubTitle = NSAttributedString(string: "Github: ",
                                                         attributes: [NSAttributedString.Key.font : prefix_font,
                                                                      NSAttributedString.Key.foregroundColor : Stylesheet.color(.darkGray)])
                    text.append(githubTitle)
                    
                    let link = github.hasPrefix("https://github") ? github : "https://github.com/\(github)"
                    let githubValue =  NSAttributedString(string: github, attributes: [.font : font, .foregroundColor : Stylesheet.color(.blue), .link :  link])
                    
                    text.append(githubValue)
                    text.append(simpleBreak)
                }
                
                // Organisation email
                let emailDescTitle = NSAttributedString(string: "Official email: ",
                                                        attributes: [NSAttributedString.Key.font : prefix_font,
                                                                     NSAttributedString.Key.foregroundColor : Stylesheet.color(.darkGray)])
                
                text.append(emailDescTitle)
                
                if let email = stellarToml.issuerDocumentation.orgOfficialEmail {
                    let link = email.hasPrefix("mailto://") ? email : "mailto://\(email)"
                    let emailValue =  NSAttributedString(string: email, attributes: [.font : font, .foregroundColor : Stylesheet.color(.blue), .link :  link])
                    
                    text.append(emailValue)
                    
                    let emailComponents = email.components(separatedBy: "@")
                    if emailComponents.count == 2, emailComponents[1] == orgHost?.removing(prefix: "www.") {
                        text.append(checkmark)
                    } else {
                        text.append(warning)
                    }
                    
                    text.append(simpleBreak)
                } else {
                    text.append(notAvailableValue)
                }
                
                // Organisation licensing authority
                if let lauth = stellarToml.issuerDocumentation.orgLicensingAuthority {
                    let lauthTitle = NSAttributedString(string: "Licensing authority: ", attributes: [NSAttributedString.Key.font : prefix_font,
                                                                                                      NSAttributedString.Key.foregroundColor : Stylesheet.color(.darkGray)])
                    text.append(lauthTitle)
                    let lauthValue = NSAttributedString(string: lauth + "\n",
                                                        attributes: [NSAttributedString.Key.font : font,
                                                                     NSAttributedString.Key.foregroundColor : Stylesheet.color(.darkGray)])
                    text.append(lauthValue)
                }
                
                // Organisation license type
                if let ltype = stellarToml.issuerDocumentation.orgLicenseType {
                    let ltypeTitle = NSAttributedString(string: "License type: ", attributes: [NSAttributedString.Key.font : prefix_font,
                                                                                               NSAttributedString.Key.foregroundColor : Stylesheet.color(.darkGray)])
                    text.append(ltypeTitle)
                    let ltypeValue = NSAttributedString(string: ltype + "\n",
                                                        attributes: [NSAttributedString.Key.font : font,
                                                                     NSAttributedString.Key.foregroundColor : Stylesheet.color(.darkGray)])
                    text.append(ltypeValue)
                }
                
                // Organisation license number
                if let lnum = stellarToml.issuerDocumentation.orgLicenseNumber {
                    let lnumTitle = NSAttributedString(string: "License number: ", attributes: [NSAttributedString.Key.font : prefix_font,
                                                                                                NSAttributedString.Key.foregroundColor : Stylesheet.color(.darkGray)])
                    text.append(lnumTitle)
                    let lnumValue = NSAttributedString(string: lnum + "\n",
                                                       attributes: [NSAttributedString.Key.font : font,
                                                                    NSAttributedString.Key.foregroundColor : Stylesheet.color(.darkGray)])
                    text.append(lnumValue)
                }
                
                // PRINCIPALS
                let principalsTitle = NSAttributedString(string: "\nPrincipals" + "\n\n", attributes: [NSAttributedString.Key.font : chapter_font,
                                                                                                       NSAttributedString.Key.foregroundColor : Stylesheet.color(.darkBlue)])
                text.append(principalsTitle)
                
                if stellarToml.pointsOfContact.count > 0 {
                    
                    for principal in stellarToml.pointsOfContact {
                        // name of principal
                        let pnameTitle = NSAttributedString(string: "Name: ", attributes: [NSAttributedString.Key.font : prefix_font,
                                                                                           NSAttributedString.Key.foregroundColor : Stylesheet.color(.darkGray)])
                        text.append(pnameTitle)
                        if let pname = principal.name {
                            let pnameValue = NSAttributedString(string: pname + "\n",
                                                                attributes: [NSAttributedString.Key.font : font,
                                                                             NSAttributedString.Key.foregroundColor : Stylesheet.color(.darkGray)])
                            text.append(pnameValue)
                        } else {
                            text.append(notAvailableValue)
                        }
                        
                        // email of principal
                        let pemailTitle = NSAttributedString(string: "Email: ", attributes: [NSAttributedString.Key.font : prefix_font,
                                                                                             NSAttributedString.Key.foregroundColor : Stylesheet.color(.darkGray)])
                        text.append(pemailTitle)
                        if let pemail = principal.email {
                            let link = pemail.hasPrefix("mailto://") ? pemail : "mailto://\(pemail)"
                            let pemailValue =  NSAttributedString(string: pemail, attributes: [.font : font, .foregroundColor : Stylesheet.color(.blue), .link :  link])
                            
                            text.append(pemailValue)
                            
                            let emailComponents = pemail.components(separatedBy: "@")
                            if emailComponents.count != 2 {
                                text.append(warning)
                            }
                            
                            text.append(simpleBreak)
                        } else {
                            text.append(notAvailableValue)
                        }
                        
                        // Principal keybase
                        if let keybase = principal.keybase {
                            let keybaseTitle = NSAttributedString(string: "Keybase: ",
                                                                  attributes: [NSAttributedString.Key.font : prefix_font,
                                                                               NSAttributedString.Key.foregroundColor : Stylesheet.color(.darkGray)])
                            text.append(keybaseTitle)
                            
                            let link = keybase.hasPrefix("https://keybase") ? keybase : "https://keybase.io/\(keybase)"
                            let keybaseValue =  NSAttributedString(string: keybase, attributes: [.font : font, .foregroundColor : Stylesheet.color(.blue), .link :  link])
                            
                            text.append(keybaseValue)
                            text.append(simpleBreak)
                        }
                        
                        // Principal telegram
                        if let telegram = principal.telegram {
                            let telegramTitle = NSAttributedString(string: "Telegram: ",
                                                                   attributes: [NSAttributedString.Key.font : prefix_font,
                                                                                NSAttributedString.Key.foregroundColor : Stylesheet.color(.darkGray)])
                            text.append(telegramTitle)
                            
                            let link = telegram.hasPrefix("http") ? telegram : "https://t.me/\(telegram)"
                            let telegramValue =  NSAttributedString(string: telegram, attributes: [.font : font, .foregroundColor : Stylesheet.color(.blue), .link :  link])
                            
                            text.append(telegramValue)
                            text.append(simpleBreak)
                        }
                        
                        // Principal twitter
                        if let twitter = principal.twitter {
                            let twitterTitle = NSAttributedString(string: "Twitter: ",
                                                                  attributes: [NSAttributedString.Key.font : prefix_font,
                                                                               NSAttributedString.Key.foregroundColor : Stylesheet.color(.darkGray)])
                            text.append(twitterTitle)
                            
                            let link = twitter.hasPrefix("https://twitter") ? twitter : "https://twitter.com/\(twitter)"
                            let twitterValue =  NSAttributedString(string: twitter, attributes: [.font : font, .foregroundColor : Stylesheet.color(.blue), .link :  link])
                            
                            text.append(twitterValue)
                            text.append(simpleBreak)
                        }
                        
                        // Principal github
                        if let github = principal.github {
                            let githubTitle = NSAttributedString(string: "Github: ",
                                                                 attributes: [NSAttributedString.Key.font : prefix_font,
                                                                              NSAttributedString.Key.foregroundColor : Stylesheet.color(.darkGray)])
                            text.append(githubTitle)
                            
                            let link = github.hasPrefix("https://github") ? github : "https://github.com/\(github)"
                            let githubValue =  NSAttributedString(string: github, attributes: [.font : font, .foregroundColor : Stylesheet.color(.blue), .link :  link])
                            
                            text.append(githubValue)
                            text.append(simpleBreak)
                        }
                        
                        // ID photo hash
                        if let idPhotoHash = principal.idPhotoHash {
                            let hashTitle = NSAttributedString(string: "Id photo hash: ",
                                                               attributes: [NSAttributedString.Key.font : prefix_font,
                                                                            NSAttributedString.Key.foregroundColor : Stylesheet.color(.darkGray)])
                            text.append(hashTitle)
                            
                            let hashValue = NSAttributedString(string: idPhotoHash,
                                                               attributes: [NSAttributedString.Key.font : font,
                                                                            NSAttributedString.Key.foregroundColor : Stylesheet.color(.darkGray)])
                            text.append(hashValue)
                            text.append(simpleBreak)
                        }
                        
                        // Verification photo hash
                        if let verificationPhotoHash = principal.verificationPhotoHash {
                            let hashTitle = NSAttributedString(string: "Verification photo hash: ",
                                                               attributes: [NSAttributedString.Key.font : prefix_font,
                                                                            NSAttributedString.Key.foregroundColor : Stylesheet.color(.darkGray)])
                            text.append(hashTitle)
                            
                            let hashValue = NSAttributedString(string: verificationPhotoHash,
                                                               attributes: [NSAttributedString.Key.font : font,
                                                                            NSAttributedString.Key.foregroundColor : Stylesheet.color(.darkGray)])
                            text.append(hashValue)
                            text.append(simpleBreak)
                        }
                        text.append(simpleBreak)
                    }
                } else {
                    text.append(notAvailableValue)
                }
                
            } else {
                let validationValue = NSAttributedString(string: "\n\nVerification failed: stellar toml file for issuer account not found." + "\n",
                                                         attributes: [NSAttributedString.Key.font : font,
                                                                      NSAttributedString.Key.foregroundColor : Stylesheet.color(.red)])
                text.append(validationValue)
            }
        }
        
        textView.attributedText = text
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        UIApplication.shared.open(URL)
        return false
    }
}
