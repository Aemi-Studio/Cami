//
//  ContentView.swift
//  Cami
//
//  Created by Guillaume Coquard on 03/11/23.
//

import EventKit
import OSLog
import SwiftUI
import WidgetKit

struct ContentView: View {
    @Environment(\.appState) private var state
    @Environment(\.presentation) private var presentation

    @AppStorage(SettingsKeys.hasDismissedOnboarding)
    private var hasDismissedOnboarding: Bool = UserDefaults.standard.bool(forKey: SettingsKeys.hasDismissedOnboarding)
    
    var fadeHeight: CGFloat? {
        UIApplication.currentWindow?.safeAreaInsets.bottom
    }

    var body: some View {
        if let state {
            NavigationStack {
                ZStack {
                    ScrollView(.vertical) {
                        VStack(spacing: 0) {
                            AppHeaderScalingHint()
                            OnboardingView()
                            
                            @Bindable var context = state.dayContext
                            SingleDayView(context: context)
                        }
                        .padding(.horizontal)
                    }
                    .safeAreaPadding(.bottom, fadeHeight)
                    .scrollClipDisabled()
                    .fadeMask()
                    .blurryEdge(edge: .bottom, position: .above, height: fadeHeight, radius: 5)

                    AppHeaderView(date: state.date)
                }
                .ignoresSafeArea(.all)
                .toolbarBackground(.hidden, for: .navigationBar)
                .toolbar(.hidden, for: .navigationBar)
            }
        }
    }
}
