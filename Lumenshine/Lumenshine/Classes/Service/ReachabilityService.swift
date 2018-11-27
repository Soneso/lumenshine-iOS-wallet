//
//  ReachabilityService.swift
//  Lumenshine
//
//  Created by Soneso on 23/11/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation
import Reachability

enum ReachabilityStatus {
    case reachableWifi
    case reachableCellular
    case unreachable
    case none
}

extension NSNotification.Name {
    static let reachableNotification = Notification.Name("reachabilityNetworkReachable")
    static let unreachableNotification = Notification.Name("reachabilityNetworkUnreachable")
}

class ReachabilityService {
    static let instance = ReachabilityService()
    private let reachability = Reachability()!
    var previousState: ReachabilityStatus = .none
    
    private init() {
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged), name: .reachabilityChanged, object: nil)
        
        do {
            try reachability.startNotifier()
        } catch {
            print("Notifier can not be started")
        }
    }
    
    deinit {
        reachability.stopNotifier()
        NotificationCenter.default.removeObserver(self)
    }
    
    func status() -> ReachabilityStatus {
        return currentStatus()
    }

    @objc private func reachabilityChanged() {
        switch currentStatus() {
        case .reachableWifi, .reachableCellular:
            sendReachableNotification()
        case .unreachable:
            sendNotReachableNotification()
        case .none:
            return
        }
        
        previousState = currentStatus()
    }
    
    private func sendNotReachableNotification() {
        NotificationCenter.default.post(name: .unreachableNotification, object: self)
    }
    
    private func sendReachableNotification() {
        NotificationCenter.default.post(name: .reachableNotification, object: self)
    }
    
    private func currentStatus() -> ReachabilityStatus {
        switch reachability.connection {
        case .wifi:
            return ReachabilityStatus.reachableWifi
        case .cellular:
            return ReachabilityStatus.reachableCellular
        case .none:
            return ReachabilityStatus.unreachable
        }
    }
}
