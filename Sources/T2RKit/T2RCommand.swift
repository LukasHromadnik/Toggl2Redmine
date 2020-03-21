import Foundation
import ArgumentParser

public struct T2RCommand: ParsableCommand {
    public static var configuration: CommandConfiguration {
        CommandConfiguration(commandName: "t2r",
                             abstract: "t2r uploads your toggl tracking times to redmine")
    }
    
    public init() {
        
    }
    
    public func run() throws {
        
    }
}
