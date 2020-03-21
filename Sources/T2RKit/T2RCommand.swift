import Foundation
import ArgumentParser
import T2RParser
import T2RUploader

public struct T2RCommand: ParsableCommand {
    public init() { }
    
    public static var configuration: CommandConfiguration {
        CommandConfiguration(commandName: "t2r",
                             abstract: "t2r uploads your toggl tracking times to redmine")
    }
    
    public func run() throws {
        let (redmineEntries, togglEntries) = Parser.shared.parseTogglEntries()
        RedmineUploader.shared.uploadRedmineEntries(redmineEntries,
                                             sortedTogglEntries: togglEntries)
    }
}
