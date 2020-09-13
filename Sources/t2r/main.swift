import ArgumentParser
import Toggl2RedmineCore

struct T2RCommand: ParsableCommand {
    static var configuration: CommandConfiguration {
        CommandConfiguration(commandName: "t2r", abstract: "t2r uploads your toggl tracking times to redmine")
    }
    
    func run() throws {
        let (redmineEntries, togglEntries) = TogglParser.shared.parseEntries()
        RedmineUploader.shared.uploadEntries(redmineEntries, sortedTogglEntries: togglEntries)
    }
}

T2RCommand.main()
