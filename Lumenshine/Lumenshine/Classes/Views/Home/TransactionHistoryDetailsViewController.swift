//
//  TransactionHistoryDetailsViewController.swift
//  Lumenshine
//
//  Created by Soneso on 21/08/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation
import UIKit

class TransactionHistoryDetailsViewController: UIViewController {
    private var titleView: TitleView!
    var operationInfo: OperationInfo!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationItem()
    }
    
    @IBAction func didTapBack(_ sender: Any) {
        self.navigationController?.dismiss(animated: true)
    }
    
    @IBAction func didTapHelp(_ sender: Any) {
    }
    
    private func setupNavigationItem() {
        titleView = Bundle.main.loadNibNamed("TitleView", owner:self, options:nil)![0] as! TitleView
        titleView.frame.size = titleView.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
        
        if let operationId = operationInfo.operationID {
            titleView.label.text = "\(operationId)\nDetails"
        }
        
        navigationItem.titleView = titleView
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image:UIImage(named: "arrow-left"), style:.plain, target: self, action: #selector(didTapBack(_:)))
        navigationItem.leftBarButtonItem?.tintColor = Stylesheet.color(.white)
        navigationItem.leftBarButtonItem?.imageInsets = UIEdgeInsetsMake(0, 2, 0, -2)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image:UIImage(named: "question"), style:.plain, target: self, action: #selector(didTapHelp(_:)))
        navigationItem.rightBarButtonItem?.tintColor = Stylesheet.color(.white)
        navigationItem.rightBarButtonItem?.imageInsets = UIEdgeInsetsMake(0, 2, 0, -2)
    }
}
