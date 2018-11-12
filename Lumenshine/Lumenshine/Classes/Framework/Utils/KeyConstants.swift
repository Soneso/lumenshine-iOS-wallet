//
//  KeyConstants.swift
//  Lumenshine
//
//  Created by Elekes Istvan on 05/11/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation

public struct Keys {

    public struct UserDefs {
        static let DestinationCurrency = "DestinationCurrencyKey"
        
        static let Notifications = "NotificationsKey"
        
        static let SelectedPeriod = "SelectedPeriodIndexKey"
        
        static let TouchID = "TouchIDKey"
        
        static let DeviceToken = "DeviceTokenKey"
        
        static let Username = "UsernameKey"
        
        static let ShowWallet = "ShowWalletKey"
    }

    
    public struct Notifications {
        static let DeviceToken = "DeviceTokenNotificationKey"
        
        static let ScrollToWallet = "ScrollToWalletNotificationKey"
    }
    
    public struct NotificationActions {
        static let View = "ViewActionIdentifier"
        
        static let Cancel = "CancelActionIdentifier"
    }
    
    public struct NotificationCategories {
        static let General = "GENERAL"
    }
}