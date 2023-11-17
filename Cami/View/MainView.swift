//
//  MainView.swift
//  Cami
//
//  Created by Guillaume Coquard on 05/11/23.
//

import SwiftUI

struct MainView: View {

    var body: some View {
        VStack {
            TabView {
                CalendarView()
                    .tabItem {
                        Label("Calendar", systemImage: "calendar")
                    }
                    .tag(1)

                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                    }
                    .tag(2)
            }
        }
    }
}

#Preview {
    MainView()
}
