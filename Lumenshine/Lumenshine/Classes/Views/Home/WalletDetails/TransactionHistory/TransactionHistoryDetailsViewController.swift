//
//  TransactionHistoryDetailsViewController.swift
//  Lumenshine
//
//  Created by Soneso on 21/08/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation
import UIKit
import Material

class TransactionHistoryDetailsViewController: UIViewController {
    private var titleView: TitleView!
    var operationInfo: OperationInfo!
    
    @IBOutlet weak var responseLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationItem()
        setupResponseLabel()
        view.backgroundColor = Stylesheet.color(.veryLightGray)
    }
    

    @IBAction func didTapHelp(_ sender: Any) {
    }
    
    private func setupNavigationItem() {
        navigationItem.titleLabel.text = "Details"
        navigationItem.titleLabel.textColor = Stylesheet.color(.white)
        navigationItem.titleLabel.font = R.font.encodeSansSemiBold(size: 15)
        
        let helpButton = Material.IconButton()
        helpButton.image = R.image.question()?.crop(toWidth: 15, toHeight: 15)?.tint(with: Stylesheet.color(.white))
        helpButton.addTarget(self, action: #selector(didTapHelp(_:)), for: .touchUpInside)
        navigationItem.rightViews = [helpButton]
    }
    
    private func setupResponseLabel() {
        guard let data = operationInfo.responseData else {
            return
        }
        responseLabel.text = String(data: data, encoding: .utf8)
    }
}
