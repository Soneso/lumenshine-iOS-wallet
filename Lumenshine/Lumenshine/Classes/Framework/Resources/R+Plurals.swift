//
//  R+Plurals.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 8/22/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation

extension R.string {
    struct plurals {        
        static func moment_year_count(_ value: Int) -> String {
            return value == 1 ? localizable.lbl_moment_year_count() : localizable.xMoment_years(value)
        }
        
        static func moment_month_count(_ value: Int) -> String {
            return value == 1 ? localizable.lbl_moment_month_count() : localizable.xMoment_months(value)
        }
        
        static func moment_week_count(_ value: Int) -> String {
            return value == 1 ? localizable.lbl_moment_week_count() : localizable.xMoment_weeks(value)
        }
        
        static func moment_day_count(_ value: Int) -> String {
            return value == 1 ? localizable.lbl_moment_day_count() : localizable.xMoment_days(value)
        }
        
        static func moment_hour_count(_ value: Int) -> String {
            return value == 1 ? localizable.lbl_moment_hour_count() : localizable.xMoment_hours(value)
        }
        
        static func moment_minute_count(_ value: Int) -> String {
            return value == 1 ? localizable.lbl_moment_minute_count() : localizable.xMoment_minutes(value)
        }
        
        static func moment_second_count(_ value: Int) -> String {
            return value == 1 ? localizable.lbl_moment_second_count() : localizable.xMoment_seconds(value)
        }
    }
}
