//
//  KeyConstants.swift
//  Lumenshine
//
//  Created by Soneso GmbH on 12/12/2018.
//  Munich, Germany
//  web: https://soneso.com
//  email: hi@soneso.com
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
        
        static let ShowMemos = "ShowMemos"
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
