//
//  MaterialIcon.swift
//  Lumenshine
//
//  Created by Soneso GmbH on 12/12/2018.
//  Munich, Germany
//  web: https://soneso.com
//  email: hi@soneso.com
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Foundation

public struct MaterialIcon {
    /**
     * A public reference to the icons bundle
     */
    public static var bundle: Bundle {
        let bundlePath =  Bundle.main.path(forResource: "MaterialIcons", ofType: "bundle")!
        return Bundle(path: bundlePath)!
    }
    
    /// Get the icon by the file name.
    public static func icon(_ name: String) -> UIImage? {
        return UIImage(named: name, in: bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
    }
    
    /// Google icons.
    public struct addCircle {
        public static let size24pt = MaterialIcon.icon("ic_add_circle")
        public static let size36pt = MaterialIcon.icon("ic_add_circle_36pt")
    }
    
    public struct addBox {
        public static let size24pt = MaterialIcon.icon("ic_add_box")
        public static let size36pt = MaterialIcon.icon("ic_add_box_36pt")
    }
    
    public struct chat {
        public static let size24pt = MaterialIcon.icon("ic_chat")
        public static let size36pt = MaterialIcon.icon("ic_chat_36pt")
    }
    
    public struct chatBuble {
        public static let size24pt = MaterialIcon.icon("ic_chat_bubble")
        public static let size36pt = MaterialIcon.icon("ic_chat_bubble_36pt")
    }
    
    public struct check {
        public static let size24 = MaterialIcon.icon("ic_check")
        public static let size36 = MaterialIcon.icon("ic_check_36pt")
    }
    
    public struct checkBoxOutline {
        public static let size24 = MaterialIcon.icon("ic_check_box_outline_blank")
    }
    
    public struct checkBox {
        public static let size24 = MaterialIcon.icon("ic_check_box")
    }
    
    public struct dateRange {
        public static let size24 = MaterialIcon.icon("ic_date_range")
        public static let size36 = MaterialIcon.icon("ic_date_range_36pt")
    }
    
    public struct home {
        public static let size24pt = MaterialIcon.icon("ic_home")
        public static let size36pt = MaterialIcon.icon("ic_home_36pt")
    }
    
    public struct insertChart {
        public static let size24pt = MaterialIcon.icon("ic_insert_chart")
        public static let size36pt = MaterialIcon.icon("ic_insert_chart_36pt")
    }
    
    public struct menu {
        public static let size36pt = MaterialIcon.icon("ic_menu_36pt")
    }
    
    public struct moreHorizontal {
        public static let size24pt = MaterialIcon.icon("ic_more_horiz")
        public static let size36pt = MaterialIcon.icon("ic_more_horiz_36pt")
    }
    
    public struct place {
        public static let size24 = MaterialIcon.icon("ic_place")
        public static let size36 = MaterialIcon.icon("ic_place_36pt")
    }
    
    public struct globe {
        public static let size24 = MaterialIcon.icon("ic_public")
        public static let size36 = MaterialIcon.icon("ic_public_36pt")
    }
    
    public struct repeatSymbol {
        public static let size24pt = MaterialIcon.icon("ic_repeat")
        public static let size36pt = MaterialIcon.icon("ic_repeat_36pt")
    }
    
    public struct star {
        public static let size24pt = MaterialIcon.icon("ic_star")
        public static let size36pt = MaterialIcon.icon("ic_star_36pt")
    }
    
    public struct starBorder {
        public static let size24pt = MaterialIcon.icon("ic_star_border")
    }
    
    public struct starHalf {
        public static let size24pt = MaterialIcon.icon("ic_star_half")
        public static let size36pt = MaterialIcon.icon("ic_star_half_36pt")
    }
    
    public struct fileUpload {
        public static let size24pt = MaterialIcon.icon("ic_file_upload")
        public static let size36pt = MaterialIcon.icon("ic_file_upload_36pt")
    }
    
    public struct person {
        public static let size24pt = MaterialIcon.icon("ic_person")
        public static let size36pt = MaterialIcon.icon("ic_person_36pt")
    }
    
    public struct email {
        public static let size24pt = MaterialIcon.icon("ic_email")
        public static let size36pt = MaterialIcon.icon("ic_email_36pt")
    }
    
    public struct localPhone {
        public static let size24pt = MaterialIcon.icon("ic_local_phone")
        public static let size36pt = MaterialIcon.icon("ic_local_phone_36pt")
    }
    
    public struct help {
        public static let size24pt = MaterialIcon.icon("ic_help_outline")
        public static let size36pt = MaterialIcon.icon("ic_help_outline_white_36pt")
    }
    
    public struct settings {
        public static let size24pt = MaterialIcon.icon("ic_settings")
        public static let size36pt = MaterialIcon.icon("ic_settings_white_36pt")
    }
    
    public struct wallets {
        public static let size24pt = MaterialIcon.icon("ic_account_balance_wallet")
        public static let size36pt = MaterialIcon.icon("ic_account_balance_wallet_white_36pt")
    }
    
    public struct transactions {
        public static let size24pt = MaterialIcon.icon("ic_format_list_bulleted")
        public static let size36pt = MaterialIcon.icon("ic_format_list_bulleted_white_36pt")
    }
    
    public struct promotions {
        public static let size24pt = MaterialIcon.icon("ic_card_giftcard")
        public static let size36pt = MaterialIcon.icon("ic_card_giftcard_white_36pt")
    }
    
    public struct account {
        public static let size48pt = MaterialIcon.icon("ic_account_circle_white_48pt")
    }
    
    public struct qrCode {
        public static let size24pt = MaterialIcon.icon("ic_qr_code")
        public static let size36pt = MaterialIcon.icon("ic_qr_code_36pt")
    }
    
    public struct send {
        public static let size24pt = MaterialIcon.icon("ic_send")
        public static let size36pt = MaterialIcon.icon("ic_send_36pt")
    }
    
    public struct received {
        public static let size24pt = MaterialIcon.icon("ic_call_received")
        public static let size36pt = MaterialIcon.icon("ic_call_received_36pt")
    }
    
    public struct money {
        public static let size24pt = MaterialIcon.icon("ic_attach_money")
        public static let size36pt = MaterialIcon.icon("ic_attach_money_36pt")
    }
    
    public struct accountBalance {
        public static let size24pt = MaterialIcon.icon("ic_account_balance")
        public static let size36pt = MaterialIcon.icon("ic_account_balance36pt")
    }
}
