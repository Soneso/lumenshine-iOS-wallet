//
//  OwnAssetsInfoViewController.swift
//  Lumenshine
//
//  Created by Soneso on 07/12/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation
import UIKit
import Material
import SwiftRichString

private enum UrlKeyWords: String {
    case here = "here"
    case stellarLaboratory = "Stellar Laboratory"
}

class OwnAssetsInfoViewController: UIViewController, UITextViewDelegate {
    @IBOutlet weak var textView: UITextView!
    
    private let modalTitle = "Own assets"
    private let urlArray = [ "https://www.stellar.org/developers/guides/concepts/assets.html",
                             "https://www.stellar.org/developers/guides/issuing-assets.html",
                             "https://www.stellar.org/developers/guides/issuing-assets.html#best-practices",
                             "https://www.stellar.org/laboratory/" ]
    
    private let infoText = "In the Stellar Network you can send any type of asset. This is a native feature of the decentralized Stellar Network. If you want to send own assets with Lumenshine you agree to take full responsibility for your own assets. Lumenshine has no control of any asset in the Stellar Network and is not responsible for any asset in the decentralized Stellar Network.\n\nRead more about assets here\nRead more about issuing assets here\n\nEach wallet in the Lumenshine app represents a stellar account. For the receivers of your own asset, to be able to receive your asset, they must add a trustline from their stellar account to the stellar account that you use to issue your own asset (issuer account).\n\nThey can do this in the details section of their wallet by adding a \"new currency\". They need the asset code and the (issuer) public key of the stellar account you are using to issue your asset.\n\nBecause an asset represents a credit, it disappears when it is sent back to the account that issued it. To better track and control the amount of your asset in circulation, you can pay a fixed amount of the asset from the issuing account to the working account that you use for normal transactions.\n\nRead more about best practices here\n\nLumenshine currently does not provide functionality to set the flags of a stellar account. This feature may be added later. In the meantime you can use Stellar Laboratory to do that if needed. Use the stellar public network to do that for accounts shown in Lumenshine."
    
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
        let ranges = infoText.ranges(of: UrlKeyWords.here.rawValue)
        let nsRanges = ranges.nsRanges
        
        for i in 0..<nsRanges.count {
            text.setAttributes([.link: urlArray[i], .font: R.font.encodeSansRegular(size: 16) as Any, .foregroundColor: Stylesheet.color(.blue)], range: nsRanges[i])
        }
        
        if let range = infoText.range(of: UrlKeyWords.stellarLaboratory.rawValue), let stellarLaboratoryLink = urlArray.last {
            let objcRange = NSMakeRange(range.lowerBound.encodedOffset, range.upperBound.encodedOffset - range.lowerBound.encodedOffset)
            text.setAttributes([.link: stellarLaboratoryLink, .font: R.font.encodeSansRegular(size: 16) as Any, .foregroundColor: Stylesheet.color(.blue)], range: objcRange)
        }
        
        textView.attributedText = text
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        let webViewController = WebViewController(title: modalTitle, url: URL.absoluteString)
        navigationController?.pushViewController(webViewController, animated: true)
        return false
    }
}
