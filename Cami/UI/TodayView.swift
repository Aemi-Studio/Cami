//
//  TodayView.swift
//  Cami
//
//  Created by Guillaume Coquard on 02/02/25.
//

import SwiftUI

struct TodayView: View {
    var body: some View {
        NavigationStack {
            ScrollView(.vertical) {
                SingleDayView(date: .now)
            }
        }
    }
}
