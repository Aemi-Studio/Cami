//
//  View+Track.swift
//  Cami
//
//  Created by Guillaume Coquard on 04.10.25.
//

import SwiftUI

extension View {
    func track(height: Binding<CGFloat>) -> some View {
        onGeometryChange(
            for: CGFloat.self,
            of: { $0.size.height },
            action: {
                if height.wrappedValue != $0 {
                    height.wrappedValue = $0
                }
            }
        )
    }
    
    func track(safeAreaInsets inset: Binding<CGFloat>, edge: Edge) -> some View {
        onGeometryChange(
            for: CGFloat.self,
            of: {
                switch edge {
                    case .top:
                        $0.safeAreaInsets.top
                    case .leading:
                        $0.safeAreaInsets.leading
                    case .bottom:
                        $0.safeAreaInsets.bottom
                    case .trailing:
                        $0.safeAreaInsets.trailing
                }
            },
            action: {
                if inset.wrappedValue != $0 {
                    inset.wrappedValue = $0
                }
            }
        )
    }
    
    func track(safeAreaInsets insets: Binding<EdgeInsets>) -> some View {
        onGeometryChange(
            for: EdgeInsets.self,
            of: { $0.safeAreaInsets },
            action: {
                if insets.wrappedValue != $0 {
                    insets.wrappedValue = $0
                }
            }
        )
    }
}
