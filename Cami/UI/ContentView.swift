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
    @Environment(\.modal) private var modal

    @AppStorage(SettingsKeys.hasDismissedOnboarding)
    private var hasDismissedOnboarding: Bool = UserDefaults.standard.bool(forKey: SettingsKeys.hasDismissedOnboarding)
    
    private var fadeHeight: CGFloat? {
        UIApplication.currentWindow?.safeAreaInsets.bottom
    }
    
    private var blurRadius: CGFloat {
        modal.menu != .none ? 7 * ((modal.presentationDetent?.order ?? 0) + 1) : 0
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
            .animation(.default, value: modal.menu)
            .animation(.default, value: modal.presentationDetent)
        }
    }
}
