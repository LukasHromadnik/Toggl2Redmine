//
//  main.swift
//  Toggl2Redmine
//
//  Created by Lukáš Hromadník on 03/03/2020.
//  Copyright © 2020 Lukáš Hromadník. All rights reserved.
//

import Foundation
import Toggl2RedmineCore

let kAutotrackerTag = "autotracker"

// Load credentials
let credentialsURL = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(".t2r/credentials.json")
let data = try! Data(contentsOf: credentialsURL)
let credentials = try! JSONDecoder().decode(Credentials.self, from: data)

struct TogglMe: Decodable {
    let defaultWorkspaceId: Int
}

var togglMeRequest = URLRequest(url: URL(string: "https://api.track.toggl.com/api/v9/me")!)
togglMeRequest.addBasicAuth(username: credentials.togglToken, password: "api_token")
let decoder = JSONDecoder()
decoder.dateDecodingStrategy = .iso8601
decoder.keyDecodingStrategy = .convertFromSnakeCase
guard
    let togglMe: TogglMe = URLSession.shared.request(togglMeRequest).decoded(using: decoder).synchronize()
else { fatalError("Cannot fetch user from Toggl") }
let defaultworksapceId = togglMe.defaultWorkspaceId

// Create a date range for time entries based on the current date
let today = Date()
let calendar = Calendar.current
guard let previousMonthDate = calendar.date(byAdding: .month, value: -1, to: today) else { fatalError("Unable to get previous month") }
guard let nextMonthDate = calendar.date(byAdding: .month, value: 1, to: today) else { fatalError("Unable to get next month") }

let previousMonthComponents = calendar.dateComponents([.month, .year], from: previousMonthDate)
let nextMonthComponents = calendar.dateComponents([.month, .year], from: nextMonthDate)

guard
    let previousYear = previousMonthComponents.year,
    let previousMonth = previousMonthComponents.month,
    let nextYear = nextMonthComponents.year,
    let nextMonth = nextMonthComponents.month
else { fatalError("Unable to load components from dates") }

let startDate = createTogglFormattedDate(forYear: previousYear, month: previousMonth)
let endDate = createTogglFormattedDate(forYear: nextYear, month: nextMonth)

// Fetch time entries within given date range
var togglTimeEntriesRequest = URLRequest(url: URL(string: "https://api.track.toggl.com/api/v9/me/time_entries?start_date=\(startDate)&end_date=\(endDate)")!)
togglTimeEntriesRequest.addBasicAuth(username: credentials.togglToken, password: "api_token")
var togglTimeEntries: [TogglEntry] = URLSession.shared.request(togglTimeEntriesRequest).decoded(using: decoder).synchronize() ?? []

// Cluster time entries and create a Redmine entry for each cluster
// Also cluster time entries based on the `spentOn` key. It's used in the update phase.
var redmineEntries: [String: [RedmineEntry]] = [:]
var sortedTogglEntries: [String: [TogglEntry]] = [:]
togglTimeEntries.forEach { entry in

    // Check if the Toggl entry is valid
    guard entry.isValid, let issueID = entry.issueID else { return }

    // Create date identifier for the current entry `YYYY-MM-dd`
    let components = calendar.dateComponents([.year, .month, .day], from: entry.start)
    guard
        let entryYear = components.year,
        let entryMonth = components.month,
        let entryDay = components.day,
        let dateIdentifier = createTogglFormattedDate(forYear: entryYear, month: entryMonth, day: entryDay).split(separator: "T").first
    else { return }

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

// Update Toggl entries and add Redmine entries
redmineEntries.forEach { value in

    // Decompose the input parameters
    let (spentOn, redmineEntries) = value

    // Update all Toggl entries for the given day
    sortedTogglEntries[spentOn]?.forEach { entry in

        // Combine Synchronized and autotracker tags with current entry's tags
        let tags = Array(Set(entry.tags + [kSynchronizedTag, kAutotrackerTag]))

        // Create request's body
        let params = ["tags": tags]

        // Create request for the update
        var request = URLRequest(url: URL(string: "https://api.track.toggl.com/api/v9/workspaces/\(defaultworksapceId)/time_entries/\(entry.id)")!)
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

print("Done")
