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

    @Environment(\.verticalSizeClass)
    private var sizeClass: UserInterfaceSizeClass?

    @State private var wasNotAuthorized: Bool = true
    @State private var isSettingsViewPresented: Bool = false
    @State private var isCalendarSelectionViewPresented: Bool = false
    @State var position: Int? = 0

    var body: some View {
        ScrollView(.vertical) {
            LazyVStack {
                ForEach(model.months!) { month in
                    MonthView(date: month.date)
                        .id(month.id)
                }
            }
            .scrollTargetLayout()
        }
        .scrollIndicators(.hidden)
        .scrollPosition(id: $position)
        .onChange(of: position) {
            Task {
                if position! >= model.last.id - 2 {
                    model.next()
                }
            }
            Task {
                if position! <= model.first.id + 2 {
                    model.prev()
                }
            }
        }
        .sheet(isPresented: $isCalendarSelectionViewPresented) {
            CalendarSelectionView().presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $isSettingsViewPresented) {
            SettingsView()
                .presentationDragIndicator(model.authStatus.calendars.status == .authorized ? .visible : .hidden)
                .presentationDetents([.medium])
                .interactiveDismissDisabled(model.authStatus.calendars.status != .authorized)
                .onDisappear {
                    if wasNotAuthorized && model.authStatus.calendars.status == .authorized {
                        model.reset()
                    }
                }
        }
        .toolbar {
            
            ToolbarItemGroup(placement: .navigation) {
                if let month = model.get(id: position!) {
                    HStack {
                        VStack {
                            Text(month.date.formatted(.dateTime.year(.defaultDigits)))
                                .monospacedDigit()
                                .font(.title2)
                                .fontWeight(.black)
                                .foregroundStyle(.background)
                                .fixedSize()
                        }
                        .padding(.vertical,2)
                        .padding(.horizontal,8)
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

            ToolbarItemGroup(placement: .bottomBar) {

                HStack(alignment: .center, spacing: 8) {

                    Spacer()

                    Button {
                        isCalendarSelectionViewPresented.toggle()
                    } label: {
                        Label("Calendars", systemImage: "calendar")
                            .labelStyle(.iconOnly)
                    }

                    Button{
                        isSettingsViewPresented.toggle()
                    } label: {
                        Label("Settings", systemImage: "gear")
                            .labelStyle(.iconOnly)
                    }
                }
            }
        }
        .toolbar(.visible, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(.visible, for: .bottomBar)
        .onAppear {
            wasNotAuthorized = model.authStatus.calendars.status != .authorized
            if wasNotAuthorized {
                isSettingsViewPresented.toggle()
            }
        }
    }
}

#Preview {
    CalendarView()
}
