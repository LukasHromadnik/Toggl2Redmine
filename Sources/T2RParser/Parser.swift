import Foundation
import T2RCore
import T2RSupport

public protocol Parsing {
    func parseTogglEntries() -> (
        redmineEntries: [String: [RedmineEntry]],
        togglEntries: [String: [TogglEntry]]
    )
}

public final class Parser: Parsing {
    public static var shared: Parsing = Parser()
    
    public func parseTogglEntries() -> (
        redmineEntries: [String: [RedmineEntry]],
        togglEntries: [String: [TogglEntry]]
    ) {
        // Load credentials
        let credentialsURL = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(".t2r/credentials.json")
        let data = try! Data(contentsOf: credentialsURL)
        let credentials = try! JSONDecoder().decode(Credentials.self, from: data)

        // Create a date range for time entries based on the current date
        let today = Date()
        let calendar = Calendar.current
        let todayComponents = calendar.dateComponents([.month, .year], from: today)

        guard let year = todayComponents.year, let month = todayComponents.month else { exit(0) }

        let startDate = createTogglFormattedDate(forYear: year, month: month)
        let endDate = createTogglFormattedDate(forYear: year, month: month + 1)

        // Fetch time entries within given date range
        var togglTimeEntriesRequest = URLRequest(url: URL(string: "https://www.toggl.com/api/v8/time_entries?start_date=\(startDate)&end_date=\(endDate)")!)
        togglTimeEntriesRequest.addBasicAuth(username: credentials.togglToken, password: "api_token")
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let togglTimeEntries: [TogglEntry] = URLSession.shared.request(togglTimeEntriesRequest).decoded(using: decoder).synchronize() ?? []

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

        return (redmineEntries: redmineEntries, togglEntries: sortedTogglEntries)
    }
}
