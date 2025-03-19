//
//  ViewHierarchy.swift
//  Realm
//
//  Created by Guillaume Coquard on 16/02/25.
//

import SwiftUI

struct ViewHierarchy: View {

    @Environment(\.presentation) private var presentation

    @State private var viewSize: CGSize? = .zero
    @State private var hierarchy: Hierarchy

    init(@ViewBuilder content: @Sendable @escaping () -> ViewContext.Content) {
        hierarchy = Hierarchy(ViewContext(content: content))
    }

    private var context: ViewContext {
        hierarchy.context
    }

    var body: some View {
        if let topBarSize = presentation.topBarSize,
           let bottomBarSize = presentation.bottomBarSize,
           let keyboardSize = presentation.keyboardSize {
            @Bindable var presentation = presentation
            //            ScrollView(.horizontal) {
            //                LazyHStack(spacing: 0) {
            AnyView(context.view)
                .scrollClipDisabled()
                .padding(.top, topBarSize.height + 16)
                .padding(.bottom, (keyboardSize > 0 ? keyboardSize : bottomBarSize.height) + 16)
                .if(keyboardSize == 0) { $0.safeAreaPadding(.bottom) }
                .containerRelativeFrame(.horizontal)
                .transition(.opacity.combined(with: .blurReplace()))
                //                }
                //                .scrollTargetLayout()
                //            }
                .padding(.horizontal, 0)
                .frame(maxWidth: .infinity)
                .update($viewSize)
                .mask(alignment: .top) {
                    DisappearingHeaderMask()
                }
                .overlay(alignment: .top) {
                    ViewTopBar()
                }
                //            .scrollPosition(id: hierarchy.position, anchor: .trailing)
                //            .defaultScrollAnchor(.trailing)
                //            .scrollClipDisabled()
                //            .scrollDisabled(true)
                //            .scrollBounceBehavior(.automatic)
                //            .scrollTargetBehavior(.viewAligned(limitBehavior: .always))
                //            .scrollIndicators(.hidden)
                .ignoresSafeArea(.all)
                .update(keyboardSize: $presentation.keyboardSize)
                .animation(.default, value: topBarSize)
                .animation(.default, value: bottomBarSize)
                .animation(.default, value: keyboardSize)
                .animation(.default, value: hierarchy.context)
                .animation(.default, value: hierarchy.context.parent)
                .environment(\.hierarchy, hierarchy)
        }
    }
}
