//
//  Helpers.swift
//  Toggl2Redmine
//
//  Created by Lukáš Hromadník on 04/03/2020.
//  Copyright © 2020 Lukáš Hromadník. All rights reserved.
//

import Foundation

/// Formats date components as a parameter for the Toggl's time entries request
///
/// - Parameters:
///   - year: Given year
///   - month: Given month
///   - day: Given day, default value is `1`
/// - Returns: Formatted date that can be used in the Toggl's time entries request
func createTogglFormattedDate(forYear year: Int, month: Int, day: Int = 1) -> String {
    let dateString = String(format: "%02d-%02d-%02dT00:00:00+00:00", year, month, day)
    return dateString
        .replacingOccurrences(of: "+", with: "%2B")
        .replacingOccurrences(of: ":", with: "%3A")
}
