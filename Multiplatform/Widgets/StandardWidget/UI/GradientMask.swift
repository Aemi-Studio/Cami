//
//  GradientMask.swift
//  Cami
//
//  Created by Guillaume Coquard on 15/03/25.
//

import SwiftUI

struct GradientMask: View {
    let direction: VerticalDirection
    
    private let colors = [Color.black, Color.black.opacity(0)]
    
    private var points: (start: UnitPoint, end: UnitPoint) {
        switch direction {
        case .up: (start: .bottom, end: .top)
        case .down: (start: .top, end: .bottom)
        }
    }

    var body: some View {
        LinearGradient(
            colors: colors,
            startPoint: points.start,
            endPoint: points.end
        )
    }
    
    enum VerticalDirection: Equatable {
        case up
        case down
    }
}
