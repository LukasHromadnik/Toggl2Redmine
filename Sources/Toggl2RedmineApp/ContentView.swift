//
//  ContentView.swift
//  Toggl2RedmineApp
//
//  Created by Lukáš Hromadník on 13/09/2020.
//  Copyright © 2020 Lukáš Hromadník. All rights reserved.
//

import SwiftUI
import Toggl2RedmineCore

struct ContentView: View {
    @State var columnWidth: CGFloat?
    @State var synchronizationType: SynchronizationType = .currentMonth
    
    @State var day = Date()
    @State var rangeFrom = Date().startOfMonth()
    @State var rangeTo = Date()
    @State var rangeLastMonthFrom = Date().startOfLastMonth()
    @State var rangeLastMonthTo = Date().endOfLastMonth()
    @State var rangeCurrentMonthFrom = Date().startOfMonth()
    @State var rangeCurrentMonthTo = Date().endOfMonth()
    
    @ObservedObject private var console = Console.shared
    
    var body: some View {
        VStack(spacing: 32) {
            Picker(selection: $synchronizationType, label: EmptyView()) {
                HStack {
                    Text("Day")
                        .frame(width: columnWidth, alignment: .leading)
                        .read(\.size.width, to: ColumnWidthKey.self)
                    datePicker(selection: $day)
                }
                .tag(SynchronizationType.day)
                HStack {
                    Text("Range")
                        .frame(width: columnWidth, alignment: .leading)
                        .read(\.size.width, to: ColumnWidthKey.self)
                    datePicker(selection: $rangeFrom)
                    Text("–")
                    datePicker(selection: $rangeTo)
                }
                .tag(SynchronizationType.range)
                HStack {
                    Text("Last month")
                        .frame(width: columnWidth, alignment: .leading)
                        .read(\.size.width, to: ColumnWidthKey.self)
                    datePicker(selection: $rangeLastMonthFrom).disabled(true)
                    Text("–")
                    datePicker(selection: $rangeLastMonthTo).disabled(true)
                }
                .tag(SynchronizationType.lastMonth)
                HStack {
                    Text("Current month")
                        .frame(width: columnWidth, alignment: .leading)
                        .read(\.size.width, to: ColumnWidthKey.self)
                    datePicker(selection: $rangeCurrentMonthFrom).disabled(true)
                    Text("–")
                    datePicker(selection: $rangeCurrentMonthTo).disabled(true)
                }
                .tag(SynchronizationType.currentMonth)
            }
            .pickerStyle(RadioGroupPickerStyle())
            .onPreferenceChange(ColumnWidthKey.self) { self.columnWidth = $0 }
            .labelsHidden()
            
            Button(
                action: {
//                    let (redmineEntries, togglEntries) = TogglParser.shared.parseEntries(within: self.selectedDateRange)
//                    RedmineUploader.shared.uploadEntries(redmineEntries, sortedTogglEntries: togglEntries)
                    Timer.scheduledTimer(withTimeInterval: 1, repeats: true) {
                        Console.shared.log("\($0.fireDate)")
                    }
                },
                label: { Text("Synchronize") }
            )
            
            ConsoleView(text: .constant(console.texts.joined(separator: "\n")))
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func datePicker(selection: Binding<Date>) -> some View {
        DatePicker(selection: selection, displayedComponents: [.date], label: { EmptyView() }).frame(width: 100)
    }
    
    private var selectedDateRange: ClosedRange<Date> {
        switch synchronizationType {
        case .day:
            return day.startOfDay()...day.endOfDay()
        case .range:
            return rangeFrom...rangeTo
        case .lastMonth:
            return rangeLastMonthFrom...rangeLastMonthTo
        case .currentMonth:
            return rangeCurrentMonthFrom...rangeCurrentMonthTo
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
