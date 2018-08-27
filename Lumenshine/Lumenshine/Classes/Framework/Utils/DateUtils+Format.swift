//
//  DateUtils+Format.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 6/15/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation

struct DateUtils {
    
}

extension DateUtils {
    enum Format: String {
        case dayName = "EEE"
        case dayNameAndTime = "EEEE d, h:mm a"
        case monthName = "MMMM"
        case monthNameAndDay = "MMM d"
        case yearAndMonth = "yyyy/MM"
        case date = "yyyy-MM-dd"
        case dateAndTime = "yyyy-MM-dd'T'HH:mm:ss'Z'"
    }
}

extension DateUtils {
    private static let dayFormatter: DateFormatter = {
        let dayFormatter = DateFormatter()
        return dayFormatter
    }()
    
    static func shortDateString(from date: Date) -> String {
        let components = NSCalendar.current.dateComponents([.hour, .minute, .second, .day, .weekOfMonth, .month, .year], from: date, to: Date())
        var dateFormat  = ""
        if let year = components.year, year > 0 {
            dateFormat = Format.date.rawValue
        } else if let weekOfMonth = components.weekOfMonth, weekOfMonth > 0 {
            dateFormat = Format.monthNameAndDay.rawValue
        } else if let day = components.day, day > 0 {
            dateFormat = Format.dayName.rawValue
        }
        
        if !dateFormat.isEmpty {
            dayFormatter.dateFormat = dateFormat
            return dayFormatter.string(from: date)
        } else {
            return R.string.localizable.lbl_today()
        }
    }
}

extension DateUtils {
    static func shortString(from fromDate: Date = Date(), to toDate: Date = Date()) -> String {
        let components = NSCalendar.current.dateComponents([.hour, .minute, .second, .day, .weekOfMonth, .month, .year], from: fromDate, to: toDate)
        var dateString  = ""
        if let year = components.year, year > 0 {
            dateString = String(format: "%ldy", year)
        } else if let month = components.month, month > 0 {
            dateString = String(format: "%ldM", month)
        } else if let weekOfMonth = components.weekOfMonth, weekOfMonth > 0 {
            dateString = String(format: "%ldW", weekOfMonth)
        } else if let day = components.day, day > 0 {
            dateString = String(format: "%ldd", day)
        } else if let hour = components.hour, hour > 0 {
            dateString = String(format: "%ldh", hour)
        } else if let minute = components.minute, minute > 0 {
            dateString = String(format: "%ldm", minute)
        } else if let second = components.second, second > 0 {
            dateString = String(format: "%lds", second)
        } else {
            dateString = R.string.localizable.lbl_now_suffix()
        }
        return dateString
    }
}

extension DateUtils {
    static func longString(from fromDate: Date, to toDate: Date = Date()) -> String {
        let components = NSCalendar.current.dateComponents([.hour, .minute, .second, .day, .weekOfMonth, .month, .year], from: fromDate, to: toDate)
        var dateString  = ""
        if let year = components.year, year > 0 {
            dateString = R.string.plurals.moment_year_count(year)
        } else if let month = components.month, month > 0 {
            dateString = R.string.plurals.moment_month_count(month)
        } else if let weekOfMonth = components.weekOfMonth, weekOfMonth > 0 {
            dateString = R.string.plurals.moment_week_count(weekOfMonth)
        } else if let day = components.day, day > 0 {
            dateString = R.string.plurals.moment_day_count(day)
        } else if let hour = components.hour, hour > 0 {
            dateString = R.string.plurals.moment_hour_count(hour)
        } else if let minute = components.minute, minute > 0 {
            dateString = R.string.plurals.moment_minute_count(minute)
        } else if let second = components.second, second > 0 {
            dateString = R.string.plurals.moment_second_count(second)
        } else {
            dateString = R.string.localizable.lbl_now_suffix()
        }
        return dateString
    }
}

extension DateUtils {
    private static let formatter = DateFormatter()
    
    static func format(_ date: Date?, in format: Format) -> String? {
        guard let date = date else { return  nil }
        formatter.dateFormat = format.rawValue
        return formatter.string(from: date)
    }
    
    static func format(_ date: String, in format: Format) -> Date? {
        formatter.dateFormat = format.rawValue
        return formatter.date(from: date)
    }
}
