//
//  MainView.swift
//  Cami
//
//  Created by Guillaume Coquard on 05/11/23.
//

import SwiftUI

struct MainView: View {

    var body: some View {
        CalendarView()
            .navigationDestination(for: Day.self, destination: DayView.init)
    }
}

#Preview {
    MainView()
}
