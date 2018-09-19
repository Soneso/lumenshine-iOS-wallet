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
    case founded
    case unfounded
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
    var unfundedView: UnfoundedWalletCardContentView?
    var viewController: UIViewController?
    
    var reloadCellAction: (() -> ())?
    var expanded = false
    
    fileprivate let textLabel = UILabel()
    //fileprivate let contentStackView = UIStackView()
    fileprivate let collapsedContainer = UIView()
    fileprivate let expandedContainer = UIView()
    
    override var viewModel: CardViewModelType? {
        didSet {
            if let viewModel = viewModel as? WalletCardViewModel {
                viewModel.receivePaymentAction = { [weak self] in
                    if self?.isSafeToAddViewController(forAction: WalletAction.receive) == true {
                        self?.expanded = true
                        self?.addViewController(forAction: WalletAction.receive)
                    }
                }
                
                viewModel.sendAction = { [weak self] in
                    if self?.isSafeToAddViewController(forAction: WalletAction.send) == true {
                        self?.expanded = true
                        self?.addViewController(forAction: WalletAction.send)
                    }
                }
            }
        }
    }
    
    var status: WalletStatus! {
        didSet {
            switch status {
            case .founded?:
                addFoundedView()
            case .unfounded?:
                addUnfoundedView()
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
    
    func addFoundedView() {
        fundedView = Bundle.main.loadNibNamed("WalletCardContentView", owner: nil, options: nil)![0] as? WalletCardContentView
        fundedView!.frame = contentView.bounds
        fundedView!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        collapsedContainer.addSubview(fundedView!)
    }
    
    func addUnfoundedView() {
        unfundedView = Bundle.main.loadNibNamed("UnfoundedWalletCardContentView", owner: nil, options: nil)![0] as? UnfoundedWalletCardContentView
        unfundedView!.frame = contentView.bounds
        unfundedView!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        collapsedContainer.addSubview(unfundedView!)
    }
    
    private var wallet: FoundedWallet {
        get {
            return ((viewModel as! WalletCardViewModel).wallet as! FoundedWallet)
        }
    }
    
    private func addViewController(forAction: WalletAction, transactionResult: TransactionResult? = nil) {
        if let parentViewController = viewController {
            var viewController: UIViewController
            
            switch (forAction) {
            case .receive:
                viewController = ReceivePaymentCardViewController()
                break
                
            case .send:
                viewController = SendViewController()
                (viewController as! SendViewController).sendAction = { [weak self] (transactionData) in
                    if let wallet = self?.wallet {
                        let transactionHelper = TransactionHelper(transactionInputData: transactionData, wallet: wallet)
                        
                        switch transactionData.transactionType {
                        case .sendPayment:
                            transactionHelper.sendPayment(completion: { (result) in
                                self?.addViewController(forAction: WalletAction.transactionResult, transactionResult: result)
                            })
                            
                        case .createAndFundAccount:
                            transactionHelper.createAndFundAccount(completion: { (result) in
                                self?.addViewController(forAction: WalletAction.transactionResult, transactionResult: result)
                            })
                        }
                    }
                }
                
            case .transactionResult:
                viewController = TransactionResultViewController()
                (viewController as! TransactionResultViewController).result = transactionResult!
                (viewController as! TransactionResultViewController).closeAllAction = { [weak self] in
                   self?.closeAllWalletActionsViewControllers()
                }
                (viewController as! TransactionResultViewController).sendOtherAction = { [weak self] in
                    self?.closeAllWalletActionsViewControllers()
                    self?.expanded = true
                    self?.addViewController(forAction: WalletAction.send)
                }
            }
            
            (viewController as! WalletActionsProtocol).wallet = (viewModel as! WalletCardViewModel).wallet
            (viewController as! WalletActionsProtocol).closeAction = { [weak self] in
                self?.closeViewController(viewController: viewController)
                self?.resetScrollView()
            }
            
            parentViewController.addChildViewController(viewController)
            expandedContainer.addSubview(viewController.view)
            
            viewController.view.snp.makeConstraints {make in
                make.edges.equalToSuperview()
            }
            
            viewController.didMove(toParentViewController: parentViewController)
            reloadCellAction?()
            
            self.resetScrollView()
        }
    }
    
    private func resetScrollView() {
        (viewController as! HomeViewController).tableView.scrollToRow(at: IndexPath(row: (viewController as! HomeViewController).dataSourceItems.index(of: self)!, section: 0), at: UITableViewScrollPosition.none, animated: true)
    }
    
    private func closeViewController(viewController: UIViewController) {
        viewController.willMove(toParentViewController: viewController)
        viewController.view.removeFromSuperview()
        viewController.removeFromParentViewController()
        reloadCellAction?()
        expanded = false
    }
    
    private func closeAllWalletActionsViewControllers() {
        if let childControllers = self.viewController?.childViewControllers {
            for viewController in childControllers {
                if let walletActionViewController = viewController as? WalletActionsProtocol {
                    if walletActionViewController.wallet.name == (viewModel as! WalletCardViewModel).wallet?.name {
                        closeViewController(viewController: viewController)
                    }
                }
            }
        }
    }
    
    private func isSafeToAddViewController(forAction action: WalletAction) -> Bool {
        guard !self.expanded else {
            if let walletActionsViewModel = self.viewController?.childViewControllers.first(where: { (walletActionController) -> Bool in
                return (walletActionController as! WalletActionsProtocol).wallet.name == (viewModel as! WalletCardViewModel).wallet?.name
            }) as? WalletActionsProtocol {
                switch (action) {
                case .receive:
                    if (walletActionsViewModel is ReceivePaymentCardViewController) {
                        return false
                    }
                    break
                
                case .send:
                    if (walletActionsViewModel is SendViewController) {
                        return false
                    }
                    break
                    
                case .transactionResult:
                    return true
                }
                
                closeAllWalletActionsViewControllers()
                return true
            }
            
            return false
        }
        
        return true
    }
}
