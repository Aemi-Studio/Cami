//
//  ContentView.swift
//  Cami
//
//  Created by Guillaume Coquard on 03/11/23.
//

import EventKit
import SwiftUI
import WidgetKit
import OSLog

struct ContentView: View {
    @Environment(\.appState) private var state
    @Environment(\.presentation) private var presentation
    
    @AppStorage(SettingsKeys.hasDismissedOnboarding)
    private var hasDismissedOnboarding: Bool = UserDefaults.standard.bool(forKey: SettingsKeys.hasDismissedOnboarding)

    var body: some View {
        if let state {
            NavigationStack {
                ZStack(alignment: .top) {
                    ScrollView(.vertical) {
                        VStack(spacing: 16) {
                            VStack(spacing: 0) {
                                AppHeaderScalingHint()
                                OnboardingView()
                            }
                            SingleDayView(context: state.dayContext)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, presentation.bottomBarSize?.height)
                    }
                    .scrollClipDisabled()
                    .headerUnderlyingMask()
                    
                    AppHeaderView(date: state.date)
                }
                .ignoresSafeArea(.all)
                .toolbarBackground(.hidden, for: .navigationBar)
                .toolbar(.hidden, for: .navigationBar)
            }
        }
    }
}
