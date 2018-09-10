//
//  LoadTransactionsHistoryViewController.swift
//  Lumenshine
//
//  Created by Soneso on 17/08/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation
import UIKit

enum InitialState {
    case showLoading
    case showButton
}

class LoadTransactionsHistoryViewController: UIViewController {
    @IBOutlet weak var transactionButtonStackView: UIStackView!
    @IBOutlet weak var transactionLabelStackView: UIStackView!
    @IBOutlet weak var activityIndicatorStackView: UIStackView!
    
    @IBAction func loadTransactionsButtonAction(_ sender: UIButton) {
        showLoadingSign()
        loadTransactionsAction?()
    }
    
    var loadTransactionsAction: (() -> ())?
    private var initialState: InitialState!
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, initialState: InitialState) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.initialState = initialState
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch initialState {
        case .showLoading:
            showLoadingSign()
            break
            
        case .showButton:
            showButton()
            break
            
        default:
            break
        }
    }
    
    func showLoadingSign() {
        transactionButtonStackView.isHidden = true
        transactionLabelStackView.isHidden = true
        activityIndicatorStackView.isHidden = false
    }
    
    func hideLoadingSign() {
        activityIndicatorStackView.isHidden = true
    }
    
    func showButton() {
        transactionButtonStackView.isHidden = false
        transactionLabelStackView.isHidden = true
        activityIndicatorStackView.isHidden = true
    }
    
    func showTitle() {
        transactionButtonStackView.isHidden = true
        transactionLabelStackView.isHidden = false
        activityIndicatorStackView.isHidden = true
    }
}
