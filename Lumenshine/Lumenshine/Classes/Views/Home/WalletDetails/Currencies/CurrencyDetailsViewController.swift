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
    
    private let normalTextAttributes: [NSAttributedStringKey : Any] = [ NSAttributedStringKey.foregroundColor: Stylesheet.color(.lightBlack), NSAttributedStringKey.font: R.font.encodeSansRegular(size: 16) as Any ]
    
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
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.paragraphSpacing = 0.5 * (font.lineHeight)
            
            let notAvailableValue = NSAttributedString(string: "not available" + "\n",
                                                   attributes: [NSAttributedStringKey.font : font,
                                                                NSAttributedStringKey.foregroundColor : Stylesheet.color(.red)])
            
            let simpleBreak = NSAttributedString(string: "\n", attributes: [NSAttributedStringKey.font : prefix_font, NSAttributedStringKey.foregroundColor : Stylesheet.color(.darkGray)])
            
            // asset code
            let assetCodePrefix = NSAttributedString(string: "Asset code: ",
                                                  attributes: [NSAttributedStringKey.font : prefix_font,
                                                               NSAttributedStringKey.foregroundColor : Stylesheet.color(.darkGray)])
            
            let assetCodeValue = NSAttributedString(string: assetCode + "\n",
                                           attributes: [NSAttributedStringKey.font : font,
                                                        NSAttributedStringKey.foregroundColor : Stylesheet.color(.darkGray)])
            
            text.append(assetCodePrefix)
            text.append(assetCodeValue)
            
            // issuer public key
            let issuerPkPrefix = NSAttributedString(string: "Issuer public key: ",
                                                     attributes: [NSAttributedStringKey.font : prefix_font,
                                                                  NSAttributedStringKey.foregroundColor : Stylesheet.color(.darkGray)])
            
            let issuerPkValue = NSAttributedString(string: issuerPk + "\n",
                                                    attributes: [NSAttributedStringKey.font : font,
                                                                 NSAttributedStringKey.foregroundColor : Stylesheet.color(.darkGray)])
            
            
            text.append(issuerPkPrefix)
            text.append(issuerPkValue)
            
            // limit
            if let limit = self.limit {
                let limitPrefix = NSAttributedString(string: "Your limit: ",
                                                        attributes: [NSAttributedStringKey.font : prefix_font,
                                                                     NSAttributedStringKey.foregroundColor : Stylesheet.color(.darkGray)])
                
                let limitValue = NSAttributedString(string: limit + "\n",
                                                       attributes: [NSAttributedStringKey.font : font,
                                                                    NSAttributedStringKey.foregroundColor : Stylesheet.color(.darkGray)])
                text.append(limitPrefix)
                text.append(limitValue)
            }
            
            // home domain
            let homeDomainPrefix = NSAttributedString(string: "Home domain: ",
                                                      attributes: [NSAttributedStringKey.font : prefix_font,
                                                                   NSAttributedStringKey.foregroundColor : Stylesheet.color(.darkGray)])
            
            text.append(homeDomainPrefix)
            
            if let homeDomain = self.homeDomain {
                
                let link = homeDomain.hasPrefix("http") ? homeDomain : "https://\(homeDomain)"
                let homeDomainValue =  NSAttributedString(string: homeDomain, attributes: [.font : font, .foregroundColor : Stylesheet.color(.blue), .link :  link])
                
                text.append(homeDomainValue)
            } else {
                text.append(notAvailableValue)
            }
            
            if invalidTomlDomain {
                let validationValue = NSAttributedString(string: "\n\nValidation failed: issuer has invalid stellar toml file" + "\n",
                                                         attributes: [NSAttributedStringKey.font : font,
                                                                      NSAttributedStringKey.foregroundColor : Stylesheet.color(.red)])
                text.append(validationValue)
            } else if invalidTomlDomain {
                let validationValue = NSAttributedString(string: "\n\nValidation failed: issuer has no stellar toml file" + "\n",
                                                         attributes: [NSAttributedStringKey.font : font,
                                                                      NSAttributedStringKey.foregroundColor : Stylesheet.color(.red)])
                text.append(validationValue)
            } else if let stellarToml = self.stellarToml {
                
                // METADATA
                let metadataTitle = NSAttributedString(string: "\n\nCurrency metadata provided by issuer" + "\n\n", attributes: [NSAttributedStringKey.font : chapter_font,
                                                                                                                      NSAttributedStringKey.foregroundColor : Stylesheet.color(.darkBlue)])
                text.append(metadataTitle)
                
                var metadataFound = false
                if stellarToml.currenciesDocumentation.count > 0 {
                    for currencyDoc in stellarToml.currenciesDocumentation {
                        //print("sac:\(self.assetCode)-\(currencyDoc.code)-sic:\(self.assetIssuerPk)-\(currencyDoc.issuer)")
                        if currencyDoc.code == self.assetCode && currencyDoc.issuer == self.assetIssuerPk {
                            metadataFound = true
                            
                            // currency status
                            let statusTitle = NSAttributedString(string: "Status: ", attributes: [NSAttributedStringKey.font : prefix_font,
                                                                                               NSAttributedStringKey.foregroundColor : Stylesheet.color(.darkGray)])
                            text.append(statusTitle)
                            if let status = currencyDoc.status {
                                let statusValue = NSAttributedString(string: status + "\n",
                                                                    attributes: [NSAttributedStringKey.font : font,
                                                                                 NSAttributedStringKey.foregroundColor : Stylesheet.color(.darkGray)])
                                text.append(statusValue)
                            } else {
                                let statusValue = NSAttributedString(string: "status is missing" + "\n",
                                                                     attributes: [NSAttributedStringKey.font : font,
                                                                                  NSAttributedStringKey.foregroundColor : Stylesheet.color(.red)])
                                text.append(statusValue)
                            }
                            
                            // short name
                            if let fname = currencyDoc.name {
                                let fnameTitle = NSAttributedString(string: "Short name: ", attributes: [NSAttributedStringKey.font : prefix_font,
                                                                                                         NSAttributedStringKey.foregroundColor : Stylesheet.color(.darkGray)])
                                text.append(fnameTitle)
                                let fnameValue = NSAttributedString(string: fname + "\n",
                                                                    attributes: [NSAttributedStringKey.font : font,
                                                                                 NSAttributedStringKey.foregroundColor : Stylesheet.color(.darkGray)])
                                text.append(fnameValue)
                            }
                            
                            // description
                            if let cdesc = currencyDoc.desc {
                                let cdescTitle = NSAttributedString(string: "Description: ", attributes: [NSAttributedStringKey.font : prefix_font,
                                                                                                                  NSAttributedStringKey.foregroundColor : Stylesheet.color(.darkGray)])
                                text.append(cdescTitle)
                                let cdescValue = NSAttributedString(string: cdesc + "\n",
                                                                    attributes: [NSAttributedStringKey.font : font,
                                                                                 NSAttributedStringKey.foregroundColor : Stylesheet.color(.darkGray)])
                                text.append(cdescValue)
                            }
                            
                            // digits
                            if let digi = currencyDoc.displayDecimals {
                                let digiTitle = NSAttributedString(string: "Display digits: ", attributes: [NSAttributedStringKey.font : prefix_font,
                                                                                                         NSAttributedStringKey.foregroundColor : Stylesheet.color(.darkGray)])
                                text.append(digiTitle)
                                let digiValue = NSAttributedString(string: "\(digi)\n",
                                                                    attributes: [NSAttributedStringKey.font : font,
                                                                                 NSAttributedStringKey.foregroundColor : Stylesheet.color(.darkGray)])
                                text.append(digiValue)
                            }
                            
                            // conditions
                            if let condi = currencyDoc.conditions {
                                let condiTitle = NSAttributedString(string: "Conditions on token: ", attributes: [NSAttributedStringKey.font : prefix_font,
                                                                                                            NSAttributedStringKey.foregroundColor : Stylesheet.color(.darkGray)])
                                text.append(condiTitle)
                                let condiValue = NSAttributedString(string: "\(condi)\n",
                                    attributes: [NSAttributedStringKey.font : font,
                                                 NSAttributedStringKey.foregroundColor : Stylesheet.color(.darkGray)])
                                text.append(condiValue)
                            }
                            
                            // image
                            if let cimage = self.currencyImage {
                                let cImageTitle = NSAttributedString(string: "Image:\n\n", attributes: [NSAttributedStringKey.font : prefix_font,
                                                                                                     NSAttributedStringKey.foregroundColor : Stylesheet.color(.darkGray)])
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
                                let fixedNrTitle = NSAttributedString(string: "Fixed number of tokens: ", attributes: [NSAttributedStringKey.font : prefix_font, NSAttributedStringKey.foregroundColor : Stylesheet.color(.darkGray)])
                                text.append(fixedNrTitle)
                                let fixedNrValue = NSAttributedString(string: "\(fixedNr)\n",
                                    attributes: [NSAttributedStringKey.font : font,
                                                 NSAttributedStringKey.foregroundColor : Stylesheet.color(.darkGray)])
                                text.append(fixedNrValue)
                            }
                            
                            // max number of tokens
                            if let maxNr = currencyDoc.maxNumber {
                                let fixedNrTitle = NSAttributedString(string: "Max number of tokens: ", attributes: [NSAttributedStringKey.font : prefix_font, NSAttributedStringKey.foregroundColor : Stylesheet.color(.darkGray)])
                                text.append(fixedNrTitle)
                                let maxNrValue = NSAttributedString(string: "\(maxNr)\n",
                                    attributes: [NSAttributedStringKey.font : font,
                                                 NSAttributedStringKey.foregroundColor : Stylesheet.color(.darkGray)])
                                text.append(maxNrValue)
                            }
                            
                            // unlimited
                            if let unlimit = currencyDoc.isUnlimited {
                                let unlimitTitle = NSAttributedString(string: "Unlimited: ", attributes: [NSAttributedStringKey.font : prefix_font, NSAttributedStringKey.foregroundColor : Stylesheet.color(.darkGray)])
                                text.append(unlimitTitle)
                                let unlimitValue = NSAttributedString(string: "\(unlimit)\n",
                                    attributes: [NSAttributedStringKey.font : font,
                                                 NSAttributedStringKey.foregroundColor : Stylesheet.color(.darkGray)])
                                text.append(unlimitValue)
                            }
                            
                            // anchored
                            if let anchored = currencyDoc.isAssetAnchored {
                                let anchoredTitle = NSAttributedString(string: "Anchored: ", attributes: [NSAttributedStringKey.font : prefix_font, NSAttributedStringKey.foregroundColor : Stylesheet.color(.darkGray)])
                                text.append(anchoredTitle)
                                let anchoredValue = NSAttributedString(string: "\(anchored)\n",
                                    attributes: [NSAttributedStringKey.font : font,
                                                 NSAttributedStringKey.foregroundColor : Stylesheet.color(.darkGray)])
                                text.append(anchoredValue)
                            }
                            
                            // anchor asset type
                            if let anchorAssetType = currencyDoc.anchorAssetType {
                                let anchoredTitle = NSAttributedString(string: "Anchor asset type: ", attributes: [NSAttributedStringKey.font : prefix_font, NSAttributedStringKey.foregroundColor : Stylesheet.color(.darkGray)])
                                text.append(anchoredTitle)
                                let anchoredValue = NSAttributedString(string: "\(anchorAssetType)\n",
                                    attributes: [NSAttributedStringKey.font : font,
                                                 NSAttributedStringKey.foregroundColor : Stylesheet.color(.darkGray)])
                                text.append(anchoredValue)
                            }
                            
                            // anchor asset
                            if let anchorAsset = currencyDoc.anchorAsset {
                                let anchoredTitle = NSAttributedString(string: "Anchor asset: ", attributes: [NSAttributedStringKey.font : prefix_font, NSAttributedStringKey.foregroundColor : Stylesheet.color(.darkGray)])
                                text.append(anchoredTitle)
                                let anchoredValue = NSAttributedString(string: "\(anchorAsset)\n",
                                    attributes: [NSAttributedStringKey.font : font,
                                                 NSAttributedStringKey.foregroundColor : Stylesheet.color(.darkGray)])
                                text.append(anchoredValue)
                            }
                            
                            // redemption instructions
                            if let redemption = currencyDoc.redemptionInstructions {
                                let redTitle = NSAttributedString(string: "Redempotion instructions: ", attributes: [NSAttributedStringKey.font : prefix_font, NSAttributedStringKey.foregroundColor : Stylesheet.color(.darkGray)])
                                text.append(redTitle)
                                let redValue = NSAttributedString(string: "\(redemption)\n",
                                    attributes: [NSAttributedStringKey.font : font,
                                                 NSAttributedStringKey.foregroundColor : Stylesheet.color(.darkGray)])
                                text.append(redValue)
                            }
                            
                            // collateral addresses
                            if currencyDoc.collateralAddresses.count > 0 {
                                let colateralTitle = NSAttributedString(string: "Collateral addresses:\n", attributes: [NSAttributedStringKey.font : prefix_font, NSAttributedStringKey.foregroundColor : Stylesheet.color(.darkGray)])
                                text.append(colateralTitle)
                            }
                            for address in currencyDoc.collateralAddresses {
                                let colateralValue = NSAttributedString(string: address + "\n", attributes: [NSAttributedStringKey.font : prefix_font, NSAttributedStringKey.foregroundColor : Stylesheet.color(.darkGray)])
                                text.append(colateralValue)
                            }
                            
                            // collateral messages
                            if currencyDoc.collateralAddressMessages.count > 0 {
                                let colateralTitle = NSAttributedString(string: "Collateral address messages:\n", attributes: [NSAttributedStringKey.font : prefix_font, NSAttributedStringKey.foregroundColor : Stylesheet.color(.darkGray)])
                                text.append(colateralTitle)
                            }
                            for message in currencyDoc.collateralAddressMessages {
                                let colateralValue = NSAttributedString(string: message + "\n", attributes: [NSAttributedStringKey.font : prefix_font, NSAttributedStringKey.foregroundColor : Stylesheet.color(.darkGray)])
                                text.append(colateralValue)
                            }
                            
                            // collateral signatures
                            if currencyDoc.collateralAddressSignatures.count > 0 {
                                let colateralTitle = NSAttributedString(string: "Collateral address signatures:\n", attributes: [NSAttributedStringKey.font : prefix_font, NSAttributedStringKey.foregroundColor : Stylesheet.color(.darkGray)])
                                text.append(colateralTitle)
                            }
                            for signature in currencyDoc.collateralAddressSignatures {
                                let colateralValue = NSAttributedString(string: signature + "\n", attributes: [NSAttributedStringKey.font : prefix_font, NSAttributedStringKey.foregroundColor : Stylesheet.color(.darkGray)])
                                text.append(colateralValue)
                            }
                            
                            // regulated
                            var regulated = false
                            if let reg = currencyDoc.regulated {
                                regulated = reg
                            }
                            let regulatedTitle = NSAttributedString(string: "Asset is regulated: ", attributes: [NSAttributedStringKey.font : prefix_font, NSAttributedStringKey.foregroundColor : Stylesheet.color(.darkGray)])
                            text.append(regulatedTitle)
                            
                            let regulatedValue = NSAttributedString(string: "\(regulated)\n",
                                attributes: [NSAttributedStringKey.font : font,
                                             NSAttributedStringKey.foregroundColor : Stylesheet.color(.darkGray)])
                            text.append(regulatedValue)
                            
                            // approval server
                            if let approvalServer = currencyDoc.approvalServer {
                                let approvalTitle = NSAttributedString(string: "Approval server: ", attributes: [NSAttributedStringKey.font : prefix_font, NSAttributedStringKey.foregroundColor : Stylesheet.color(.darkGray)])
                                text.append(approvalTitle)
                                let approvalValue = NSAttributedString(string: "\(approvalServer)\n",
                                    attributes: [NSAttributedStringKey.font : font,
                                                 NSAttributedStringKey.foregroundColor : Stylesheet.color(.darkGray)])
                                text.append(approvalValue)
                            }
                            
                            // approval criteria
                            if let approvalCriteria = currencyDoc.approvalCriteria {
                                let approvalTitle = NSAttributedString(string: "Approval criteria: ", attributes: [NSAttributedStringKey.font : prefix_font, NSAttributedStringKey.foregroundColor : Stylesheet.color(.darkGray)])
                                text.append(approvalTitle)
                                let approvalValue = NSAttributedString(string: "\(approvalCriteria)\n",
                                    attributes: [NSAttributedStringKey.font : font,
                                                 NSAttributedStringKey.foregroundColor : Stylesheet.color(.darkGray)])
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
                let documentationTitle = NSAttributedString(string: "\n\nIssuer Documentation" + "\n\n", attributes: [NSAttributedStringKey.font : chapter_font,
                                                                                                                      NSAttributedStringKey.foregroundColor : Stylesheet.color(.darkBlue)])
                text.append(documentationTitle)
                
                // Organisation name
                let orgNameTitle = NSAttributedString(string: "Organisation name: ", attributes: [NSAttributedStringKey.font : prefix_font,
                                                                                                  NSAttributedStringKey.foregroundColor : Stylesheet.color(.darkGray)])
                text.append(orgNameTitle)
                
                if let name = stellarToml.issuerDocumentation.orgName {
                    let nameValue = NSAttributedString(string: name + "\n",
                                                           attributes: [NSAttributedStringKey.font : font,
                                                                        NSAttributedStringKey.foregroundColor : Stylesheet.color(.darkGray)])
                    text.append(nameValue)
                    
                } else {
                    text.append(notAvailableValue)
                }
                
                // Organisation dba
                if let dba = stellarToml.issuerDocumentation.orgDBA {
                    let orgDbaTitle = NSAttributedString(string: "Doing business as: ", attributes: [NSAttributedStringKey.font : prefix_font,
                                                                                                     NSAttributedStringKey.foregroundColor : Stylesheet.color(.darkGray)])
                    text.append(orgDbaTitle)
                    let dbaValue = NSAttributedString(string: dba + "\n",
                                                       attributes: [NSAttributedStringKey.font : font,
                                                                    NSAttributedStringKey.foregroundColor : Stylesheet.color(.darkGray)])
                    text.append(dbaValue)
                }
                
                // Organisation url
                let orgUrlTitle = NSAttributedString(string: "URL: ", attributes: [NSAttributedStringKey.font : prefix_font,
                                                                                   NSAttributedStringKey.foregroundColor : Stylesheet.color(.darkGray)])
                text.append(orgUrlTitle)
                
                if let orgUrl = stellarToml.issuerDocumentation.orgURL {
                    
                    let link = orgUrl.hasPrefix("http") ? orgUrl : "https://\(orgUrl)"
                    let orgUrlValue =  NSAttributedString(string: orgUrl, attributes: [.font : font, .foregroundColor : Stylesheet.color(.blue), .link :  link])
                    
                    text.append(orgUrlValue)
                    text.append(simpleBreak)
                    
                } else {
                    text.append(notAvailableValue)
                }
                
                // Organisation logo
                if let logo = self.organisationLogo {
                    let logoTitle = NSAttributedString(string: "Logo:\n\n", attributes: [NSAttributedStringKey.font : prefix_font,
                                                                                         NSAttributedStringKey.foregroundColor : Stylesheet.color(.darkGray)])
                    text.append(logoTitle)
                    let logoAttachment = NSTextAttachment()
                    logoAttachment.image = logo
                    let logoString = NSAttributedString(attachment: logoAttachment)
                    text.append(logoString)
                    text.append(simpleBreak)
                    text.append(simpleBreak)
                }
                
                // Organisation description
                let orgDescTitle = NSAttributedString(string: "Description: ", attributes: [NSAttributedStringKey.font : prefix_font,
                                                                                            NSAttributedStringKey.foregroundColor : Stylesheet.color(.darkGray)])
                text.append(orgDescTitle)
                
                if let desc = stellarToml.issuerDocumentation.orgDescription {
                    let descValue = NSAttributedString(string: desc + "\n",
                                                       attributes: [NSAttributedStringKey.font : font,
                                                                    NSAttributedStringKey.foregroundColor : Stylesheet.color(.darkGray)])
                    text.append(descValue)
                    
                } else {
                    text.append(notAvailableValue)
                }
                
                // Organisation physical address
                let addressDescTitle = NSAttributedString(string: "Physical address: ",
                                                          attributes: [NSAttributedStringKey.font : prefix_font,
                                                                       NSAttributedStringKey.foregroundColor : Stylesheet.color(.darkGray)])
                
                text.append(addressDescTitle)
                
                if let address = stellarToml.issuerDocumentation.orgPhysicalAddress {
                    let addressValue = NSAttributedString(string: address + "\n",
                                                       attributes: [NSAttributedStringKey.font : font,
                                                                    NSAttributedStringKey.foregroundColor : Stylesheet.color(.darkGray)])
                    text.append(addressValue)
                    
                } else {
                    text.append(notAvailableValue)
                }
                
                // Organisation physical address atestation
                if let addressAtestation = stellarToml.issuerDocumentation.orgPhysicalAddressAttestation {
                    let aATitle = NSAttributedString(string: "Physical address atestation: ",
                                                              attributes: [NSAttributedStringKey.font : prefix_font,
                                                                           NSAttributedStringKey.foregroundColor : Stylesheet.color(.darkGray)])
                    text.append(aATitle)
                    
                    let link = addressAtestation.hasPrefix("http") ? addressAtestation : "https://\(addressAtestation)"
                    let aAValue =  NSAttributedString(string: addressAtestation, attributes: [.font : font, .foregroundColor : Stylesheet.color(.blue), .link :  link])
                    
                    text.append(aAValue)
                    text.append(simpleBreak)
                }
                
                // Organisation phone number
                let phoneDescTitle = NSAttributedString(string: "Phone number: ",
                                                          attributes: [NSAttributedStringKey.font : prefix_font,
                                                                       NSAttributedStringKey.foregroundColor : Stylesheet.color(.darkGray)])
                
                text.append(phoneDescTitle)
                
                if let phone = stellarToml.issuerDocumentation.orgPhoneNumber {
                    let link = phone.hasPrefix("tel://") ? phone : "tel://\(phone)"
                    let phoneValue =  NSAttributedString(string: phone, attributes: [.font : font, .foregroundColor : Stylesheet.color(.blue), .link :  link])
                    
                    text.append(phoneValue)
                    text.append(simpleBreak)
                    
                    // Organisation phone number atestation
                    if let phoneAtestation = stellarToml.issuerDocumentation.orgPhysicalAddressAttestation {
                        let pATitle = NSAttributedString(string: "Phone number atestation: ",
                                                         attributes: [NSAttributedStringKey.font : prefix_font,
                                                                      NSAttributedStringKey.foregroundColor : Stylesheet.color(.darkGray)])
                        text.append(pATitle)
                        
                        let link = phoneAtestation.hasPrefix("http") ? phoneAtestation : "https://\(phoneAtestation)"
                        let pAValue =  NSAttributedString(string: phoneAtestation, attributes: [.font : font, .foregroundColor : Stylesheet.color(.blue), .link :  link])
                        
                        text.append(pAValue)
                        text.append(simpleBreak)
                    }
                    
                } else {
                    text.append(notAvailableValue)
                }
                
                // Organisation keybase
                if let keybase = stellarToml.issuerDocumentation.orgKeybase {
                    let keybaseTitle = NSAttributedString(string: "Keybase: ",
                                                     attributes: [NSAttributedStringKey.font : prefix_font,
                                                                  NSAttributedStringKey.foregroundColor : Stylesheet.color(.darkGray)])
                    text.append(keybaseTitle)
                    
                    let link = keybase.hasPrefix("https://keybase") ? keybase : "https://keybase.io/\(keybase)"
                    let keybaseValue =  NSAttributedString(string: keybase, attributes: [.font : font, .foregroundColor : Stylesheet.color(.blue), .link :  link])
                    
                    text.append(keybaseValue)
                    text.append(simpleBreak)
                }
                
                // Organisation twitter
                if let twitter = stellarToml.issuerDocumentation.orgTwitter {
                    let twitterTitle = NSAttributedString(string: "Twitter: ",
                                                          attributes: [NSAttributedStringKey.font : prefix_font,
                                                                       NSAttributedStringKey.foregroundColor : Stylesheet.color(.darkGray)])
                    text.append(twitterTitle)
                    
                    let link = twitter.hasPrefix("https://twitter") ? twitter : "https://twitter.com/\(twitter)"
                    let twitterValue =  NSAttributedString(string: twitter, attributes: [.font : font, .foregroundColor : Stylesheet.color(.blue), .link :  link])
                    
                    text.append(twitterValue)
                    text.append(simpleBreak)
                }
            
                // Organisation github
                if let github = stellarToml.issuerDocumentation.orgGithub{
                    let githubTitle = NSAttributedString(string: "Github: ",
                                                         attributes: [NSAttributedStringKey.font : prefix_font,
                                                                      NSAttributedStringKey.foregroundColor : Stylesheet.color(.darkGray)])
                    text.append(githubTitle)
                    
                    let link = github.hasPrefix("https://github") ? github : "https://github.com/\(github)"
                    let githubValue =  NSAttributedString(string: github, attributes: [.font : font, .foregroundColor : Stylesheet.color(.blue), .link :  link])
                    
                    text.append(githubValue)
                    text.append(simpleBreak)
                }
                
                // Organisation email
                let emailDescTitle = NSAttributedString(string: "Official email: ",
                                                        attributes: [NSAttributedStringKey.font : prefix_font,
                                                                     NSAttributedStringKey.foregroundColor : Stylesheet.color(.darkGray)])
                
                text.append(emailDescTitle)
                
                if let email = stellarToml.issuerDocumentation.orgOfficialEmail {
                    let link = email.hasPrefix("mailto://") ? email : "mailto://\(email)"
                    let emailValue =  NSAttributedString(string: email, attributes: [.font : font, .foregroundColor : Stylesheet.color(.blue), .link :  link])
                    
                    text.append(emailValue)
                    text.append(simpleBreak)
                } else {
                    text.append(notAvailableValue)
                }
                
                // Organisation licensing authority
                if let lauth = stellarToml.issuerDocumentation.orgLicensingAuthority {
                    let lauthTitle = NSAttributedString(string: "Licensing authority: ", attributes: [NSAttributedStringKey.font : prefix_font,
                                                                                                     NSAttributedStringKey.foregroundColor : Stylesheet.color(.darkGray)])
                    text.append(lauthTitle)
                    let lauthValue = NSAttributedString(string: lauth + "\n",
                                                      attributes: [NSAttributedStringKey.font : font,
                                                                   NSAttributedStringKey.foregroundColor : Stylesheet.color(.darkGray)])
                    text.append(lauthValue)
                }
                
                // Organisation license type
                if let ltype = stellarToml.issuerDocumentation.orgLicenseType {
                    let ltypeTitle = NSAttributedString(string: "License type: ", attributes: [NSAttributedStringKey.font : prefix_font,
                                                                                                      NSAttributedStringKey.foregroundColor : Stylesheet.color(.darkGray)])
                    text.append(ltypeTitle)
                    let ltypeValue = NSAttributedString(string: ltype + "\n",
                                                        attributes: [NSAttributedStringKey.font : font,
                                                                     NSAttributedStringKey.foregroundColor : Stylesheet.color(.darkGray)])
                    text.append(ltypeValue)
                }
                
                // Organisation license number
                if let lnum = stellarToml.issuerDocumentation.orgLicenseNumber {
                    let lnumTitle = NSAttributedString(string: "License number: ", attributes: [NSAttributedStringKey.font : prefix_font,
                                                                                               NSAttributedStringKey.foregroundColor : Stylesheet.color(.darkGray)])
                    text.append(lnumTitle)
                    let lnumValue = NSAttributedString(string: lnum + "\n",
                                                        attributes: [NSAttributedStringKey.font : font,
                                                                     NSAttributedStringKey.foregroundColor : Stylesheet.color(.darkGray)])
                    text.append(lnumValue)
                }
                
                // PRINCIPALS
                if stellarToml.pointsOfContact.count > 0 {
                    
                    let principalsTitle = NSAttributedString(string: "\nPrincipals" + "\n\n", attributes: [NSAttributedStringKey.font : chapter_font,
                                                                                                                          NSAttributedStringKey.foregroundColor : Stylesheet.color(.darkBlue)])
                    text.append(principalsTitle)
                    
                    for principal in stellarToml.pointsOfContact {
                        // name of principal
                        let pnameTitle = NSAttributedString(string: "Name: ", attributes: [NSAttributedStringKey.font : prefix_font,
                                                                                                    NSAttributedStringKey.foregroundColor : Stylesheet.color(.darkGray)])
                        text.append(pnameTitle)
                        if let pname = principal.name {
                            let pnameValue = NSAttributedString(string: pname + "\n",
                                                               attributes: [NSAttributedStringKey.font : font,
                                                                            NSAttributedStringKey.foregroundColor : Stylesheet.color(.darkGray)])
                            text.append(pnameValue)
                        } else {
                            text.append(notAvailableValue)
                        }
                        
                        // email of principal
                        let pemailTitle = NSAttributedString(string: "Email: ", attributes: [NSAttributedStringKey.font : prefix_font,
                                                                                           NSAttributedStringKey.foregroundColor : Stylesheet.color(.darkGray)])
                        text.append(pemailTitle)
                        if let pemail = principal.email {
                            let link = pemail.hasPrefix("mailto://") ? pemail : "mailto://\(pemail)"
                            let pemailValue =  NSAttributedString(string: pemail, attributes: [.font : font, .foregroundColor : Stylesheet.color(.blue), .link :  link])
                            
                            text.append(pemailValue)
                            text.append(simpleBreak)
                        } else {
                            text.append(notAvailableValue)
                        }
                        
                        // Principal keybase
                        if let keybase = principal.keybase {
                            let keybaseTitle = NSAttributedString(string: "Keybase: ",
                                                                  attributes: [NSAttributedStringKey.font : prefix_font,
                                                                               NSAttributedStringKey.foregroundColor : Stylesheet.color(.darkGray)])
                            text.append(keybaseTitle)
                            
                            let link = keybase.hasPrefix("https://keybase") ? keybase : "https://keybase.io/\(keybase)"
                            let keybaseValue =  NSAttributedString(string: keybase, attributes: [.font : font, .foregroundColor : Stylesheet.color(.blue), .link :  link])
                            
                            text.append(keybaseValue)
                            text.append(simpleBreak)
                        }
                        
                        // Principal twitter
                        if let twitter = principal.twitter {
                            let twitterTitle = NSAttributedString(string: "Twitter: ",
                                                                  attributes: [NSAttributedStringKey.font : prefix_font,
                                                                               NSAttributedStringKey.foregroundColor : Stylesheet.color(.darkGray)])
                            text.append(twitterTitle)
                            
                            let link = twitter.hasPrefix("https://twitter") ? twitter : "https://twitter.com/\(twitter)"
                            let twitterValue =  NSAttributedString(string: twitter, attributes: [.font : font, .foregroundColor : Stylesheet.color(.blue), .link :  link])
                            
                            text.append(twitterValue)
                            text.append(simpleBreak)
                        }
                        
                        // Organisation github
                        if let github = principal.github {
                            let githubTitle = NSAttributedString(string: "Github: ",
                                                                 attributes: [NSAttributedStringKey.font : prefix_font,
                                                                              NSAttributedStringKey.foregroundColor : Stylesheet.color(.darkGray)])
                            text.append(githubTitle)
                            
                            let link = github.hasPrefix("https://github") ? github : "https://github.com/\(github)"
                            let githubValue =  NSAttributedString(string: github, attributes: [.font : font, .foregroundColor : Stylesheet.color(.blue), .link :  link])
                            
                            text.append(githubValue)
                            text.append(simpleBreak)
                        }
                        text.append(simpleBreak)
                    }
                }
                
            } else {
                let validationValue = NSAttributedString(string: "\n\nValidation failed: stellar toml file for issuer not found" + "\n",
                                                         attributes: [NSAttributedStringKey.font : font,
                                                                      NSAttributedStringKey.foregroundColor : Stylesheet.color(.red)])
                text.append(validationValue)
            }
        }
        
        textView.attributedText = text
        
        /*for (key, links) in linksDict {
            let ranges = infoText.ranges(of: key)
            let nsRanges = ranges.nsRanges
            
            for i in 0..<nsRanges.count {
                if links.count > i {
                    text.setAttributes([.link: links[i], .font: R.font.encodeSansRegular(size: 16) as Any, .foregroundColor: Stylesheet.color(.blue)], range: nsRanges[i])
                }
            }
        }
        
        for chapter in chapters {
            let ranges = infoText.ranges(of: chapter)
            let nsRanges = ranges.nsRanges
            
            for i in 0..<nsRanges.count {
                text.setAttributes([.font: R.font.encodeSansSemiBold(size: 16) as Any, .foregroundColor: Stylesheet.color(.orange)], range: nsRanges[i])
            }
        }
        
        for bold in bolds {
            let ranges = infoText.ranges(of: bold)
            let nsRanges = ranges.nsRanges
            
            for i in 0..<nsRanges.count {
                text.setAttributes([.font: R.font.encodeSansSemiBold(size: 16) as Any, .foregroundColor: Stylesheet.color(.darkGray)], range: nsRanges[i])
            }
        }*/
        
        textView.attributedText = text
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        UIApplication.shared.open(URL)
        return false
    }
}
