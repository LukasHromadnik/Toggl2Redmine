//
//  Console.swift
//  Toggl2RedmineCore
//
//  Created by Lukáš Hromadník on 13/09/2020.
//  Copyright © 2020 Lukáš Hromadník. All rights reserved.
//

import Combine

public class Console: ObservableObject {
    public static let shared = Console()
    
    @Published public var texts: [String] = []
    
    public func log(_ text: String) {
        print(text)
        DispatchQueue.main.async { [weak self] in
            self?.texts.append(text)
        }
    }
}
