//
//  CalendarView.swift
//  Cami
//
//  Created by Guillaume Coquard on 15/11/23.
//

import SwiftUI

struct CalendarView: View {

    @Environment(ViewModel.self)
    private var model: ViewModel

    @Environment(PermissionModel.self)
    private var perms: PermissionModel

    @Environment(\.verticalSizeClass)
    private var sizeClass: UserInterfaceSizeClass?

    @State
    private var wasNotAuthorized: Bool = true

    @Binding
    var areSettingsPresented: Bool

    @State
    private var isCalendarSelectionViewPresented: Bool = false

    var body: some View {

        @Bindable var model = model
        @Bindable var perms = perms

        ScrollView(.vertical) {
            LazyVStack(spacing: 8) {
                ForEach(model.months!) { month in
                    MonthView(date: month.date)
                        .id(month.id)
                }
            }
            .scrollTargetLayout()
        }
        .scrollIndicators(.hidden)
        .scrollPosition(id: $model.position)
        .sheet(isPresented: $isCalendarSelectionViewPresented) {
            CalendarSelectionView()
                .presentationDragIndicator(.visible)
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigation) {
                if let month = model.first(id: model.position!) {
                    HStack {
                        VStack {
                            Text(month.date.formatted(.dateTime.year(.defaultDigits)))
                                .monospacedDigit()
                                .font(.title2)
                                .fontWeight(.black)
                                .foregroundStyle(.background)
                                .fixedSize()
                        }
                        .padding(.vertical, 2)
                        .padding(.horizontal, 8)
                        .background(.foreground)
                        .clipShape(RoundedRectangle(cornerRadius: 6))

                        Text(
                            month.date.formatted(.dateTime.month(.wide))
                        )
                        .font(.title)
                        .fontWeight(.heavy)
                        .foregroundStyle(.foreground)
                    }
                } else {
                    EmptyView()
                }
            }
            #if os(macOS)
            ToolbarItemGroup(placement: .principal) {
                HStack(alignment: .center, spacing: 8) {
                    Spacer()
                    Button {
                        isCalendarSelectionViewPresented.toggle()
                    } label: {
                        Label("Calendars", systemImage: "calendar")
                            .labelStyle(.iconOnly)
                    }
                    Button {
                        areSettingsPresented.toggle()
                    } label: {
                        Label("Settings", systemImage: "gear")
                            .labelStyle(.iconOnly)
                    }
                }
            }
            #else
            ToolbarItemGroup(placement: .bottomBar) {
                HStack(alignment: .center, spacing: 8) {
                    Spacer()
                    Button {
                        isCalendarSelectionViewPresented.toggle()
                    } label: {
                        Label("Calendars", systemImage: "calendar")
                            .labelStyle(.iconOnly)
                    }
                    Button {
                        areSettingsPresented.toggle()
                    } label: {
                        Label("Settings", systemImage: "gear")
                            .labelStyle(.iconOnly)
                    }
                }
            }
            #endif
        }
        #if os(iOS)
        .toolbar(.visible, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(.visible, for: .bottomBar)
        #endif
    }
}
