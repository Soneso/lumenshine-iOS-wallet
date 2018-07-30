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

protocol WalletCardProtocol {
    
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
                viewModel.receivePaymentAction = {
                    guard !self.expanded else {
                        return
                    }
                    self.expanded = true
                    self.addReceiveViewController()
                }
            }
        }
    }
    
    var status: WalletStatus! {
        didSet {
            switch status {
            case .founded:
                addFoundedView()
            case .unfounded:
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
    
    func addReceiveViewController() {
        if let parentViewController = viewController {
            let viewController = ReceivePaymentCardViewController()
            viewController.wallet = (viewModel as! WalletCardViewModel).wallet
            viewController.closeAction = {
                viewController.willMove(toParentViewController: parentViewController)
                viewController.view.removeFromSuperview()
                viewController.removeFromParentViewController()
                
                self.reloadCellAction?()
                self.expanded = false
            }
            
            parentViewController.addChildViewController(viewController)
            expandedContainer.addSubview(viewController.view)
            viewController.view.snp.makeConstraints {make in
                make.edges.equalToSuperview()
            }
            viewController.didMove(toParentViewController: parentViewController)
            
            
            reloadCellAction?()
        }
    }
    
}
