import Foundation
import ArgumentParser
import Toggl2RedmineCore

let formatter = DateFormatter()
formatter.dateFormat = "dd.MM.yyyy"

struct Toggle2Redmine: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "t2r",
        abstract: "t2r uploads your toggl tracking times to redmine"
    )
    
    // MARK: - Options
    
    @Option(
        help: "Synchronizes entries from a single day. Format: dd.MM.yyyy",
        transform: { formatter.date(from: $0) })
    var day: Date?
    
    @Option(
        parsing: .upToNextOption,
        help: "Synchronizes entries between two days (including). Format: dd.MM.yyyy dd.MM.yyyy (from, to respectively). Current date is used when only one argument is provided.",
        transform: { formatter.date(from: String($0)) ?? Date() })
    var range: [Date] = []
    
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
            let to = Calendar.current.date(byAdding: components, to: today.startOfMonth())!
            return to.startOfMonth()...to
        } else {
            return today.startOfMonth()...today.endOfMonth()
        }
    }
    
    func validate() throws {
        if range.isEmpty == false && (1..<3).contains(range.count) == false {
            throw ValidationError("Range can only have one or two input values!")
        }
    }
    
    func run() throws {
        let (redmineEntries, togglEntries) = TogglParser.shared.parseEntries(within: dateRange)
        RedmineUploader.shared.uploadEntries(redmineEntries, sortedTogglEntries: togglEntries)
    }
}

Toggle2Redmine.main()

print("Done")
