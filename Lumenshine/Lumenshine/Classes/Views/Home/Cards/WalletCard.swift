//
//  WalletCard.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 6/19/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material
import SnapKit

enum WalletStatus {
    case funded
    case unfunded
}

enum WalletAction {
    case receive
    case send
    case transactionResult
}

protocol WalletCardProtocol {
    
}

protocol WalletActionsProtocol: class {
    var wallet: Wallet! { get set }
    var closeAction: (() -> ())? { get set }
}

class WalletCard: CardView {
    
    var fundedView: WalletCardContentView?
    var unfundedView: UnfundedWalletCardContentView?
    var viewController: UIViewController?
    
    var reloadCellAction: (() -> ())?
    var expanded = false
    
    fileprivate let textLabel = UILabel()
    //fileprivate let contentStackView = UIStackView()
    fileprivate let collapsedContainer = UIView()
    fileprivate let expandedContainer = UIView()
    fileprivate var paymentOperationsVCManager: PaymentOperationsVCManager!
    override var viewModel: CardViewModelType? {
        didSet {
            if let viewModel = viewModel as? WalletCardViewModel {
                viewModel.receivePaymentAction = {
                    self.setupPaymentOperationsVCManager()
                    self.paymentOperationsVCManager.addViewController(forAction: WalletAction.receive, wallet: self.wallet)
                }
                
                viewModel.sendAction = {
                    self.setupPaymentOperationsVCManager()
                    self.paymentOperationsVCManager.addViewController(forAction: WalletAction.send, wallet: self.wallet)
                }
            }
        }
    }
    
    var status: WalletStatus! {
        didSet {
            switch status {
            case .funded?:
                addFundedView()
            case .unfunded?:
                addUnfundedView()
            default:
                print("error")
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        prepare()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupPaymentOperationsVCManager() {
        if self.paymentOperationsVCManager == nil {
            if let viewController = self.viewController {
                self.paymentOperationsVCManager = PaymentOperationsVCManager(parentViewController: viewController)
            }
        }
    }
}

fileprivate extension WalletCard {
    func prepare() {
        addContainers()
    }
    
    func addContainers() {
        collapsedContainer.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(collapsedContainer)
        expandedContainer.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(expandedContainer)
        
        collapsedContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        collapsedContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        collapsedContainer.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        
        expandedContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        expandedContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        let topAnchor = expandedContainer.topAnchor.constraint(equalTo: collapsedContainer.bottomAnchor)
        topAnchor.priority = .defaultHigh
        topAnchor.isActive = true
        expandedContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        
        let heightConstraint = expandedContainer.heightAnchor.constraint(equalToConstant: 0)
        heightConstraint.priority = .defaultLow
        heightConstraint.isActive = true
    }
    
    func addFundedView() {
        fundedView = Bundle.main.loadNibNamed("WalletCardContentView", owner: nil, options: nil)![0] as? WalletCardContentView
        fundedView!.frame = contentView.bounds
        fundedView!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        collapsedContainer.addSubview(fundedView!)
    }
    
    func addUnfundedView() {
        unfundedView = Bundle.main.loadNibNamed("UnfundedWalletCardContentView", owner: nil, options: nil)![0] as? UnfundedWalletCardContentView
        unfundedView!.frame = contentView.bounds
        unfundedView!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        collapsedContainer.addSubview(unfundedView!)
    }
    
    private var wallet: FundedWallet {
        get {
            return ((viewModel as! WalletCardViewModel).wallet as! FundedWallet)
        }
    }
}
