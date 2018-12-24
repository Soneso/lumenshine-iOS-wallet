//
//  WebSocketService.swift
//  Lumenshine
//
//  Created by Soneso GmbH on 12/12/2018.
//  Munich, Germany
//  web: https://soneso.com
//  email: hi@soneso.com
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation
import Starscream

extension NSNotification.Name {
    static let subscribeForUpdates = Notification.Name("subscribeForUpdatesNotification")
    static let unsubscribeForUpdates = Notification.Name("unsubscribeForUpdatesNotification")
    static let refreshWalletsNotification = Notification.Name("refreshWalletsNotification")
    static let updateUIAfterWalletRefresh = Notification.Name("updateUIAfterWalletRefreshNotification")
}

public class WebSocketService: BaseService, WebSocketDelegate {
    private static var socket: WebSocket!
    private static var randomKey: String?
    private static var cachedWallets: [WalletsResponse]!
    
    public static var subscribers = NSMapTable<UIViewController, InitializationState>(keyOptions: NSPointerFunctions.Options.weakMemory, valueOptions: NSPointerFunctions.Options.strongMemory)
    
    static var instance: WebSocketService!
    static var wallets: [WalletsResponse]! {
        didSet {
            WebSocketService.instance.listenToAllAccounts()
        }
    }
    
    private var userManager: UserManager {
        get {
            return Services.shared.userManager
        }
    }
    
    override init(baseURL: String) {
        super.init(baseURL: baseURL)
        WebSocketService.instance = self
        registerNotifications()
    }

    public func websocketDidConnect(socket: WebSocketClient) {
        print("WebSocketDidConnect with RandomKey: \(WebSocketService.randomKey!)")
        WebSocketService.cachedWallets = nil
        listenToAllAccounts()
    }
    
    public func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        print("WebSocketDidDisconnect: \((error as? WSError)?.code ?? -9999)")
    }
    
    public func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        print("WebSocketDidReceiveMessage: \(text)")
        let accountsToUpdate = getAccountsID(fromMessage: text)
        for account in accountsToUpdate {
            Services.shared.walletService.removeCachedAccountDetails(accountId: account)
            Services.shared.walletService.addWalletToRefresh(accountId: account)
        }
        NotificationCenter.default.post(name: .refreshWalletsNotification, object: true)
    }
    
    public func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        print("WebSocketDidReceiveData: \(data)")
        NotificationCenter.default.post(name: .refreshWalletsNotification, object: true)
    }
    
    func connectWebSocket() {
        if WebSocketService.socket?.isConnected == true {
            return
        }
        
        setupWebSocket()
        WebSocketService.socket?.connect()
    }
    
    func disconnectWebSocket() {
        if WebSocketService.socket?.isConnected == true {
            WebSocketService.cachedWallets = nil
            WebSocketService.socket?.disconnect(forceTimeout: 0)
            removeWebSocket()
        }
    }
    
    @objc func subscribedForUpdates(notification:NSNotification) {
        if let viewController = notification.object as? UIViewController, let isViewControllerSubscribed = WebSocketService.subscribers.object(forKey: viewController)?.isInitialized {
            if !isViewControllerSubscribed {
                connectWebSocket()
                WebSocketService.subscribers.object(forKey: viewController)?.isInitialized = true
            }
        }
    }
    
    @objc func unsubscribedForUpdates() {
        if WebSocketService.subscribers.count == 0 {
            disconnectWebSocket()
        }
    }
    
    @objc func networkChanged() {
        if WebSocketService.socket == nil
            || ReachabilityService.instance.previousState == .none
            || ReachabilityService.instance.status() == ReachabilityService.instance.previousState {
            return
        }
        
        connectWebSocket()
    }
    
    @objc func networkUnreachable() {
        if WebSocketService.socket == nil {
            return
        }
        
        disconnectWebSocket()
    }
    
    private func getAccountsID(fromMessage text: String) -> [String] {
        let removedPrefixes = text.replacingOccurrences(of: "{\"account\":\"", with: "")
        let formattedText = removedPrefixes.replacingOccurrences(of: "\"}", with: "")
        let splittedValues = formattedText.split(separator: "\n", maxSplits: 2, omittingEmptySubsequences: true)
        
        var accountsArray = [String]()
        for account in splittedValues {
            accountsArray.append(String(account))
        }

        return accountsArray
    }
    
    private func registerNotifications() {
        registerSubsciptionNotifications()
        registerNetworkChangesNotifications()
    }
    
    private func registerSubsciptionNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.subscribedForUpdates),
            name: .subscribeForUpdates,
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.unsubscribedForUpdates),
            name: .unsubscribeForUpdates,
            object: nil)
    }
    
    private func registerNetworkChangesNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.networkChanged),
            name: .reachableNotification,
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.networkUnreachable),
            name: .unreachableNotification,
            object: nil)
    }
    
    private func listenToAllAccounts() {
        if WebSocketService.wallets?.count == WebSocketService.cachedWallets?.count || WebSocketService.socket == nil {
            return
        } else if let walletsCount = WebSocketService.wallets?.count, let cachedWalletsCount = WebSocketService.cachedWallets?.count, walletsCount > cachedWalletsCount {
            if let wallets = WebSocketService.wallets {
                for index in cachedWalletsCount...walletsCount - 1 {
                    listenAccount(withAccountID: wallets[index].publicKey)
                }
            }
            
            return
        }
        
        if let wallets = WebSocketService.wallets {
            for wallet in wallets {
                listenAccount(withAccountID: wallet.publicKey)
            }
            
            WebSocketService.cachedWallets = wallets
        }
    }
    
    private func setupWebSocket() {
        if WebSocketService.socket?.isConnected == true {
            return
        }
        
        WebSocketService.randomKey = generateRandomKey()
        
        var request = URLRequest(url: URL(string: "\(baseURL)/portal/sse/get_ws?random_key=\(WebSocketService.randomKey!)")!)
        request.setValue(BaseService.jwtToken, forHTTPHeaderField: "Authorization")
        WebSocketService.socket = WebSocket(request: request)
        WebSocketService.socket.delegate = self
    }

    private func listenAccount(withAccountID account:String) {
        var params = Dictionary<String, Any>()
        params["key"] = WebSocketService.randomKey
        params["account"] = account
        
        POSTRequestWithPath(path: "/portal/sse/listen_account", parameters: params) { (response) -> (Void) in
            switch response {
            case .success(data: _):
                print("Listening to \(account) with success!")
                
            case .failure(error: let error):
                print("Listening to \(account) failed with error: \(error.localizedDescription)")
            }
        }
    }
    
   private func removeAccount(withAccountID account: String) {
        var params = Dictionary<String, Any>()
        params["key"] = WebSocketService.randomKey
        params["account"] = account

        POSTRequestWithPath(path: "/portal/sse/remove_account", parameters: params) { (response) -> (Void) in
            switch response {
            case .success(data: _):
                print("Stopped listening to \(account) with success!")
            case .failure(error: let error):
                print("Stopping listening to \(account) failed with error: \(error.localizedDescription)")
            }
        }
    }
    
    private func removeWebSocket() {
        if WebSocketService.socket?.isConnected == true {
            return
        }
        
        var params = Dictionary<String, Any>()
        params["key"] = WebSocketService.randomKey
        
        POSTRequestWithPath(path: "/portal/sse/remove_ws", parameters: params, completion: {_ in })
    }
    
    private func generateRandomKey() -> String {
        var randomKey: String = ""
        
        while randomKey.count < 32 {
            let rng = String(arc4random_uniform(99))
            randomKey.append(rng)
        }
        
        return randomKey
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.subscribeForUpdates, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.unsubscribeForUpdates, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.reachableNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.unreachableNotification, object: nil)
    }
}
