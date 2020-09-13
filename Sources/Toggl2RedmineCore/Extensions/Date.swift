//
//  Date.swift
//
//
//  Created by Vendula Švastalová on 02/09/2020.
//

import Foundation

extension Date {
    public func startOfDay(for calendar: Calendar = .current) -> Date {
        calendar.startOfDay(for: self)
    }

    public func endOfDay(for calendar: Calendar = .current) -> Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return calendar.date(byAdding: components, to: startOfDay())!
    }

    public func startOfMonth(for calendar: Calendar = .current) -> Date {
        let components = calendar.dateComponents([.year, .month], from: startOfDay())
        return calendar.date(from: components)!
    }

    public func endOfMonth(for calendar: Calendar = .current) -> Date {
        var components = DateComponents()
        components.month = 1
        components.second = -1
        return calendar.date(byAdding: components, to: startOfMonth())!
    }
    
    public func startOfLastMonth(for calendar: Calendar = .current) -> Date {
        var components = DateComponents()
        components.month = -1
        return calendar.date(byAdding: components, to: Date())!.startOfMonth()
    }
    
    public func endOfLastMonth(for calendar: Calendar = .current) -> Date {
        var components = DateComponents()
        components.month = -1
        return calendar.date(byAdding: components, to: Date())!.endOfMonth()
    }
    
    /// Formatted date that can be used in the Toggl's time entries request
    public func togglFormattedString(for calendar: Calendar = .current) -> String? {
        let components = calendar.dateComponents([.day, .month, .year, .hour, .minute, .second], from: self)
        
        guard
            let year = components.year,
            let month = components.month,
            let day = components.day,
            let hour = components.hour,
            let minute = components.minute,
            let second = components.second
            else { return nil }
        
        let dateString = String(format: "%02d-%02d-%02dT%02d:%02d:%02d+00:00", year, month, day, hour, minute, second)
        return dateString
            .replacingOccurrences(of: "+", with: "%2B")
            .replacingOccurrences(of: ":", with: "%3A")
    }
}
