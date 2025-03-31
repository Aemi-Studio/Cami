//
//  NavigationPageLink.swift
//  Cami
//
//  Created by Guillaume Coquard on 02/02/25.
//

import SwiftUI

struct NavigationPageLink<Destination: View>: View {
    let title: String
    let image: String
    let destination: () -> Destination

    init(
        _ title: String,
        image: String = "chevron.forward",
        @ViewBuilder destination: @escaping () -> Destination
    ) {
        self.title = title
        self.image = image
        self.destination = destination
    }

    var body: some View {
        NavigationLink {
            destination()
                .navigationStackStyleReset()

        } label: {
            Label(title, systemImage: image)
        }
        .buttonStyle(.accentWithOutline)
    }
}

extension View {
    func navigationStackStyleReset() -> some View {
        toolbarNavigationBackgroundHidden()
            .containerNavigationBackground()
            .transition(.blurReplace)
    }

    @ViewBuilder func toolbarNavigationBackgroundHidden() -> some View {
        modifier(ResetToolbarBackground())
    }
}

struct ResetToolbarBackground: ViewModifier {
    @State private var height: CGFloat = 0

    @ViewBuilder private func hideToolbar(@ViewBuilder content: () -> some View) -> some View {
        if #available(iOS 18.0, *) {
            content().toolbarBackgroundVisibility(.hidden, for: .navigationBar)
        } else {
            content().toolbarBackground(.hidden, for: .navigationBar)
        }
    }

    @ViewBuilder private func applyMaskAndBlur(@ViewBuilder content: () -> some View) -> some View {
        content()
            .padding(.bottom, height * 2)
            .ignoresSafeArea(.all, edges: .bottom)
            .scrollClipDisabled()
            .scrollIndicators(.hidden)
            .mask(alignment: .top) {
                DisappearingHeaderMask(height: height)
                    .offset(y: -height)
            }
            .overlay(alignment: .top) {
                VariableBlurView(maxBlurRadius: 10)
                    .frame(height: height)
                    .frame(maxWidth: .infinity)
                    .offset(y: -height)
            }
            .background {
                GeometryReader { proxy in
                    Color.clear
                        .preference(key: ToolbarHeightPreferenceKey.self, value: proxy.safeAreaInsets.top)
                        .onPreferenceChange(ToolbarHeightPreferenceKey.self) { newHeight in
                            Task(priority: .utility) { @MainActor in
                                if newHeight != height {
                                    height = newHeight
                                }
                            }
                        }
                }
            }
            .padding(.bottom, -height * 2)
    }

    struct ToolbarHeightPreferenceKey: PreferenceKey {
        static let defaultValue: CGFloat = 0
        static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
            value = nextValue()
        }
    }

    func body(content: Content) -> some View {
        hideToolbar {
            applyMaskAndBlur {
                content
            }
        }
    }
}
