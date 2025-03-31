//
//  ProgressCircle.swift
//  Cami
//
//  Created by Guillaume Coquard on 13/03/25.
//

import AemiUI
import SwiftUI

struct ProgressCircle: View {
    @State private var size = CGSize.zero
    private(set) var progress: Double
    private(set) var lineWidthRatio: Double

    private var strokeLineWidth: Double {
        min(size.width, size.height) * lineWidthRatio
    }

    private var scaleFactor: Double {
        1.0 / (1.0 + lineWidthRatio)
    }

    private var tint: some ShapeStyle {
        TintShapeStyle()
    }

    init(progress: Double, lineWidthRatio: Double = 0.15) {
        self.progress = progress
        self.lineWidthRatio = lineWidthRatio
    }

    var body: some View {
        ZStackLayout {
            Circle()
                .stroke(lineWidth: strokeLineWidth)
                .foregroundStyle(tint.quaternary)

            Circle()
                .trim(from: 0.0, to: CGFloat(min(progress, 1.0)))
                .stroke(
                    style: StrokeStyle(
                        lineWidth: strokeLineWidth,
                        lineCap: .round,
                        lineJoin: .round
                    )
                )
                .foregroundStyle(tint)
                .rotationEffect(.degrees(-90))
                .animation(.linear, value: progress)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .aspectRatio(1, contentMode: .fit)
        .scaleEffect(scaleFactor)
        .update($size)
    }
}
