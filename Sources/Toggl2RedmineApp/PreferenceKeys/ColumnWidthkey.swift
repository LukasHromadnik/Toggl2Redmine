//
//  ColumnWidthkey.swift
//  Toggl2RedmineApp
//
//  Created by Lukáš Hromadník on 13/09/2020.
//  Copyright © 2020 Lukáš Hromadník. All rights reserved.
//

import SwiftUI

struct ColumnWidthKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}
