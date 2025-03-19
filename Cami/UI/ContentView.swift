//
//  ContentView.swift
//  Cami
//
//  Created by Guillaume Coquard on 03/11/23.
//

import EventKit
import SwiftUI
import WidgetKit

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.path) private var path
    @Environment(\.presentation) private var presentation
    @Environment(\.permissions) private var permissions
    @Environment(\.views) private var views

    private var wasNotAuthorized: Bool = PermissionContext.shared.global == .restricted

    private var authorized: Bool {
        permissions.global == .authorized
    }

    private var restricted: Bool {
        permissions.global == .restricted
    }

    var body: some View {
        setModalsUp {
            NavigationStack {
                ZStack {
                    SingleDayView(date: .now)
                    MenuOverlayView()
                }
                .ignoresSafeArea(.all)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .toolbarBackground(.hidden, for: .navigationBar)
                .toolbar(.hidden, for: .navigationBar)
            }
        }
    }

    @ViewBuilder
    private func setModalsUp(@ViewBuilder content: @escaping () -> some View) -> some View {
        @Bindable var presentation = presentation
        content()
            .modal(isPresented: $presentation.areSettingsPresented) {
                CustomSettingsView().defaultModalSetup()
            }
            .modal(isPresented: $presentation.areInformationsPresented) {
                KnowledgeBaseView().defaultModalSetup()
            }
            .modal(isPresented: $presentation.isCreationSheetPresented) {
                CreateCalendarItemView().defaultModalSetup()
            }
            .modal(isPresented: $presentation.isWidgetPreviewSheetPresented) {
                WidgetPreviewView().defaultModalSetup()
            }
    }
}

extension View {
    fileprivate func defaultModalSetup() -> some View {
        presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
            .presentationContentInteraction(.scrolls)
    }
}

#Preview {
    ContentView()
}
