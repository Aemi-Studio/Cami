//
//  BorderedToggle.swift
//  Cami
//
//  Created by Guillaume Coquard on 30/03/25.
//

import AemiUI
import SwiftUI

struct BorderedToggle<Content: View>: View {
    typealias Placement = NativeToggleCheckboxStyle.Placement
    
    @Binding private(set) var isOn: Bool
    
    private(set) var backgroundStyle: any ShapeStyle = Color.primary.tertiary
    private(set) var outline = true
    private(set) var placement: Placement = .trailing
    
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        CustomBordered(backgroundStyle: Color.primary.tertiary, outline: true) {
            Toggle(isOn: $isOn, label: content)
            .toggleStyle(.nativeCheckbox(placement: placement))
            .padding(.trailing, -2)
        }
    }
}
