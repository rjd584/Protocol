//
//  ConsoleView.swift
//  Protocol
//
//  Created by Rob Del Gatto on 11/6/22.
//

import SwiftUI

struct ConsoleView: View {
    @EnvironmentObject var settings: SettingsStore
    @StateObject var lines = Console.instance

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack {
                    ForEach(lines.lines, id: \.id) { line in
                        Text(line.getMessage(stamped: settings.consoleStampsEnabled))
                            .textSelection(.enabled)
                            .frame(maxWidth: .infinity, alignment: .bottomLeading)
                    }
                    .onChange(of: lines.lines) { line in
                        proxy.scrollTo(lines.lines[lines.lines.count-1].id)
                    }
                }
            }
        }
    }
}

struct ConsoleView_Previews: PreviewProvider {
    static var previews: some View {
        ConsoleView()
    }
}
