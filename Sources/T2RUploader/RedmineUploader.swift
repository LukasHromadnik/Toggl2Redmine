import T2RCore
import T2RSupport
import Foundation

public protocol RedmineUploading {
    func uploadRedmineEntries(_ redmineEntries: [String: [RedmineEntry]],
                              sortedTogglEntries: [String: [TogglEntry]])
}

public final class RedmineUploader: RedmineUploading {
    public func uploadRedmineEntries(_ redmineEntries: [String: [RedmineEntry]],
                                     sortedTogglEntries: [String: [TogglEntry]]) {
        let kAutotrackerTag = "autotracker"
        
        // Load credentials
        let credentialsURL = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(".t2r/credentials.json")
        let data = try! Data(contentsOf: credentialsURL)
        let credentials = try! JSONDecoder().decode(Credentials.self, from: data)
        
        // Update Toggl entries and add Redmine entries
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

        print("Done")
    }
}
