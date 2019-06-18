//
//  HelpDetailsViewController.swift
//  Lumenshine
//
//  Created by Soneso GmbH on 12/12/2018.
//  Munich, Germany
//  web: https://soneso.com
//  email: hi@soneso.com
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation
import UIKit
import Material
import SwiftRichString

class HelpDetailsViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var textView: UITextView!
    
    public var modalTitle = "Help"
    public var infoText = ""
    public var linksDict = [String: [String]]()
    public var chapters = [String]()
    public var bolds = [String]()
    
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
        
        for (key, links) in linksDict {
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
        }
        
        textView.attributedText = text
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        UIApplication.shared.open(URL)
        return false
    }
}
