//
//  HiddenIf.swift
//  Cami
//
//  Created by Guillaume Coquard on 16/11/23.
//

import SwiftUI

struct HiddenIf: ViewModifier {

    var condition: Bool = false

    init(condition: Bool = false) {
        self.condition = condition
    }

    init(condition: @escaping (Any...) -> Bool) {
        self.condition = condition(self)
    }

    func body(content: Content) -> some View {
        if condition {
            EmptyView()
        } else {
            content
        }
    }
}

extension View {

    public func hiddenIf(_ condition: Bool = false) -> some View {
        modifier(HiddenIf(condition: condition))
    }

    public func hiddenIf(_ condition: @escaping (Any...) -> Bool) -> some View {
        modifier(HiddenIf(condition: condition))
    }

}
