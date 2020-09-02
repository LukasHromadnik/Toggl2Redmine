//
//  main.swift
//  Toggl2Redmine
//
//  Created by Lukáš Hromadník on 03/03/2020.
//  Copyright © 2020 Lukáš Hromadník. All rights reserved.
//

import Foundation
import ArgumentParser

let kAutotrackerTag = "autotracker"

let formatter = DateFormatter()
formatter.dateFormat = "dd.MM.yyyy"

let calendar = Calendar.current

var redmineEntries: [String: [RedmineEntry]] = [:]
var sortedTogglEntries: [String: [TogglEntry]] = [:]

func loadCredentials() -> Credentials {
    let credentialsURL = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(".t2r/credentials.json")
    let data = try! Data(contentsOf: credentialsURL)
    return try! JSONDecoder().decode(Credentials.self, from: data)
}

func fetchTogglEntries(from range: ClosedRange<Date>, with credentials: Credentials) -> [TogglEntry] {
    guard
        let startDate = range.lowerBound.togglFormattedString(),
        let endDate = range.upperBound.togglFormattedString()
        else { return [] }
    
    var togglTimeEntriesRequest = URLRequest(url: URL(string: "https://www.toggl.com/api/v8/time_entries?start_date=\(startDate)&end_date=\(endDate)")!)
    togglTimeEntriesRequest.addBasicAuth(username: credentials.togglToken, password: "api_token")
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    return URLSession.shared.request(togglTimeEntriesRequest).decoded(using: decoder).synchronize() ?? []
}

/// Cluster time entries and create a Redmine entry for each cluster.
/// Also cluster time entries based on the `spentOn` key. It's used in the update phase.
func createRedmineEntries(from togglEntries: [TogglEntry]) {
    togglEntries.forEach { entry in

        // Check if the Toggl entry is valid
        guard entry.isValid, let issueID = entry.issueID else { return }

        // Create date identifier for the current entry `YYYY-MM-dd`
        let components = Calendar.current.dateComponents([.year, .month, .day], from: entry.start)
        guard let dateIdentifier = components.date?.togglFormattedString()?.split(separator: "T").first else { return }

        // Just case the `Substring` to `String`
        let spentOn = String(dateIdentifier)

        // Initialize the dictionary for the given date if needed
        // Also initialize the dictionary for sorted entries
        if redmineEntries[spentOn] == nil {
            redmineEntries[spentOn] = []
            sortedTogglEntries[spentOn] = []
        }

        // Add the entry to the given key in the `sortedTogglEntries`
        sortedTogglEntries[spentOn]?.append(entry)

        // Load and update the issue or create a new one
        if let issue = redmineEntries[spentOn]?.first(where: { $0.issueID == issueID }) {
            issue.duration += entry.duration
            if let comment = entry.comment {
                issue.addComment(comment)
            }
        } else {
            let issue = RedmineEntry(issueID: issueID, duration: entry.duration, spentOn: spentOn)
            if let comment = entry.comment {
                issue.addComment(comment)
            }
            redmineEntries[spentOn]?.append(issue)
        }
    }
}

/// Update Toggl entries and add Redmine entries
func updateRedmineWithEntries(credentials: Credentials) {
    redmineEntries.forEach { value in

        // Decompose the input parameters
        let (spentOn, redmineEntries) = value

        // Update all Toggl entries for the given day
        sortedTogglEntries[spentOn]?.forEach { entry in

            // Combine Synchronized and autotracker tags with current entry's tags
            let tags = Array(Set(entry.tags + [kSynchronizedTag, kAutotrackerTag]))

            // Create request's body
            let params = ["time_entry": ["tags": tags]]

            // Create request for the update
            var request = URLRequest(url: URL(string: "https://www.toggl.com/api/v8/time_entries/\(entry.id)")!)
            request.addBasicAuth(username: credentials.togglToken, password: "api_token")
            request.httpMethod = "PUT"
            request.setJSONBody(params)

            print("Updating " + entry.description)

            // Run the request synchronously
            _ = URLSession.shared.request(request).synchronize()
        }

        // Add new entries to the Redmine
        redmineEntries.forEach { entry in

            // Create request for each entry
            var request = URLRequest(url: URL(string: "https://redmine.ack.ee/time_entries.json")!)
            request.httpMethod = "POST"
            request.allHTTPHeaderFields = [
                "X-Redmine-API-Key": credentials.redmineToken,
                // Without this the request will fail
                "Content-Type": "application/json"
            ]

            let commentsSuffix = " (" + kAutotrackerTag + ")"

            // Add suffix to the comments entry
            var comments = entry.formattedComments + commentsSuffix

            // Remove leading space if the entry has no comments
            if comments.count == commentsSuffix.count {
                comments = String(comments.dropFirst())
            }

            // Create request's body
            let params = [
                "time_entry": [
                    "issue_id": entry.issueID,
                    "hours": entry.hours,
                    "comments": comments,
                    "spent_on": spentOn
                ]
            ]
            request.setJSONBody(params)

            print("Adding time entry to the #\(entry.issueID)")

            // Run the request synchronously
            _ = URLSession.shared.request(request).synchronize()
        }
    }
}

struct Toggle2Redmine: ParsableCommand {
    
    // MARK: - Options
    
    @Option(
        help: "Synchronizes entries from a single day. Format: dd.MM.yyyy",
        transform: { formatter.date(from: $0) })
    var day: Date?
    
    @Option(
        parsing: .upToNextOption,
        help: "Synchronizes entries between two days (including). Format: dd.MM.yyyy dd.MM.yyyy (from, to respectively). Current date is used when only one argument is provided.",
        transform: { formatter.date(from: String($0)) ?? Date() })
    var range: [Date]
    
    // MARK: - Flags
    
    @Flag(help: "Synchronizes entries from the specified month.")
    var lastMonth: Bool = false
    
    @Flag(help: "Synchronizes entries from the current month. Used as the default option when none other is provided.")
    var currentMonth: Bool = false
    
    // MARK: - Private properties
    
    /// Computes closed range of dates from provided arguments. When no arguments are provided current month range is used as default.
    private var dateRange: ClosedRange<Date> {
        let today = Date()
        
        if let day = day {
            return day.startOfDay()...day.endOfDay()
        } else if !range.isEmpty {
            let ordered = range.sorted(by: <)
            return ordered[0]...ordered[1]
        } else if lastMonth {
            var components = DateComponents()
            components.second = -1
            let to = calendar.date(byAdding: components, to: today.startOfMonth())!
            return to.startOfMonth()...to
        } else {
            return today.startOfMonth()...today.endOfMonth()
        }
    }
    
    func validate() throws {
        if !(1..<3).contains(range.count) {
            throw ValidationError("Range can only have one or two input values!")
        }
    }
    
    func run() throws {
        let credentials = loadCredentials()
        let togglEntries = fetchTogglEntries(from: dateRange, with: credentials)
        createRedmineEntries(from: togglEntries)
        updateRedmineWithEntries(credentials: credentials)
    }
}

Toggle2Redmine.main()

print("Done")
