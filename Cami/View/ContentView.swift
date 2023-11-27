//
//  ContentView.swift
//  Cami
//
//  Created by Guillaume Coquard on 03/11/23.
//

import SwiftUI

struct ContentView: View {

    @Bindable
    var model: ViewModel

    var body: some View {
        NavigationStack(path: $model.path) {
            CalendarView()
                .navigationDestination(for: Day.self) { day in
                    DayView(day)
                }
        }
    }
}
