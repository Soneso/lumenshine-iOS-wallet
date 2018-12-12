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
                NotificationCenter.default.addObserver(self, selector: #selector(reloadWallets), name: NSNotification.Name.reloadWalletsNotification, object: nil)
            } else {
                NotificationCenter.default.addObserver(self, selector: #selector(updateUIAfterWalletsReload), name: NSNotification.Name.updateUIAfterWalletsReload, object: nil)
            }
        }
    }
    
    deinit {
        WebSocketService.subscribers.removeObject(forKey: self)
        NotificationCenter.default.post(name: .unsubscribeForUpdates, object: self)
        if hasWallets {
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.reloadWalletsNotification, object: nil)
        } else {
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.updateUIAfterWalletsReload, object: nil)
        }
        
        print("UpdatableViewController deinit")
    }
    
    @objc func reloadWallets() { }
    @objc func updateUIAfterWalletsReload(notification: NSNotification) { }
}
