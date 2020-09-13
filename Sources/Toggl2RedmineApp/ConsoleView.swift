//
//  ConsoleView.swift
//  Toggl2RedmineApp
//
//  Created by Lukáš Hromadník on 13/09/2020.
//  Copyright © 2020 Lukáš Hromadník. All rights reserved.
//

import SwiftUI

struct ConsoleView: View {
    @Binding var text: String
    
    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                Text(self.text)
                    .padding(4)
                    .font(.system(size: 12, design: .monospaced))
                .lineLimit(5)
                .fixedSize(horizontal: false, vertical: true)
            }
            .frame(width: proxy.size.width, alignment: .topLeading)
            .background(Rectangle().foregroundColor(.white))
        }
    }
}

struct ConsoleView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ConsoleView(text: .constant("Konzole"))
            ConsoleView(text: .constant([1, 2, 3, 4, 5, 6, 7, 8, 9, 10].map(String.init).joined(separator: "\n")))
        }
    }
}
