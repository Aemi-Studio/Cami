//
//  ThinBorder.swift
//  Cami
//
//  Created by Guillaume Coquard on 31/03/25.
//

import SwiftUI

extension View {
    func thinBorder(
        radius: CGFloat,
        color: any ShapeStyle = Color.primary.quaternary,
        lineWidth: CGFloat = 0.5
    ) -> some View {
        overlay {
            RoundedRectangle(cornerRadius: radius)
                .fill(.clear)
                .stroke(AnyShapeStyle(color), lineWidth: lineWidth)
        }
    }
}
