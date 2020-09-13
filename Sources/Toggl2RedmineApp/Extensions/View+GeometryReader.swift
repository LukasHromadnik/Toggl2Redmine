//
//  View+GeometryReader.swift
//  Toggl2RedmineApp
//
//  Created by Lukáš Hromadník on 13/09/2020.
//  Copyright © 2020 Lukáš Hromadník. All rights reserved.
//

import SwiftUI

extension View {
    /// Reads value from `GeometryProxy` on given `View` and stores it as a given `PreferenceKey`
    ///
    /// We have to call the `preference(key:value:)` method on `Color.clear`,
    /// because `EmptyView` is not working at the moment
    /// - Parameters:
    ///   - `keyPath`: KeyPath on `GeometryProxy` which value is then processed
    ///   - `preferenceKey`: `PreferenceKey` in which the value is stored
    /// - Returns: Overlay with applied `GeometryReader`
    func read<Value, Key>(_ keyPath: KeyPath<GeometryProxy, Value>, to preferenceKey: Key.Type) -> some View where Key: PreferenceKey, Value == Key.Value {
        overlay(
            GeometryReader { proxy in
                Color.clear.preference(key: preferenceKey, value: proxy[keyPath: keyPath])
            }
        )
    }
}
