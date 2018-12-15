//
//  UpdatableViewController.swift
//  Lumenshine
//
//  Created by Soneso GmbH on 12/12/2018.
//  Munich, Germany
//  web: https://soneso.com
//  email: hi@soneso.com
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit

public class InitializationState {
    var isInitialized: Bool = false
}

public class UpdatableViewController: UIViewController {
    var hasWallets = false
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        if WebSocketService.subscribers.keyEnumerator().contains(where: { (key) -> Bool in
            return (key as? UIViewController) == self
        }) == false {
            WebSocketService.subscribers.setObject(InitializationState(), forKey: self)
            NotificationCenter.default.post(name: .subscribeForUpdates, object: self)
            if hasWallets {
                NotificationCenter.default.addObserver(self, selector: #selector(refreshWallets), name: NSNotification.Name.refreshWalletsNotification, object: nil)
            } else {
                NotificationCenter.default.addObserver(self, selector: #selector(updateUIAfterWalletRefresh), name: NSNotification.Name.updateUIAfterWalletRefresh, object: nil)
            }
        }
    }
    
    deinit {
        cleanup()
        print("UpdatableViewController deinit")
    }
    
    public func cleanup() {
        
        WebSocketService.subscribers.removeObject(forKey: self)
        NotificationCenter.default.post(name: .unsubscribeForUpdates, object: self)
        if hasWallets {
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.refreshWalletsNotification, object: nil)
        } else {
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.updateUIAfterWalletRefresh, object: nil)
        }
    }
    
    @objc func refreshWallets(notification: NSNotification) { }
    @objc func updateUIAfterWalletRefresh(notification: NSNotification) { }
}
