//
//  NavigationPageLink.swift
//  Cami
//
//  Created by Guillaume Coquard on 05.10.25.
//

import SwiftUI

struct NavigationPageLink<Destination>: View where Destination: View {
    @Environment(AppNavigation.self) private var appNavigation
    
    private let title: String
    private let image: String
    private let typedDestination: NavigationDestination?
    private let viewDestination: (() -> Destination)?

    init(
        _ title: String,
        image: String = "chevron.forward",
        @ViewBuilder destination: @escaping () -> Destination
    ) {
        self.title = title
        self.image = image
        self.typedDestination = nil
        self.viewDestination = destination
    }
    
    init(
        _ title: String,
        image: String = "chevron.forward",
        destination: NavigationDestination
    ) where Destination == Never {
        self.title = title
        self.image = image
        self.typedDestination = destination
        self.viewDestination = nil
    }
    
    @State private var scrollOffset = CGFloat.zero

    var body: some View {
        navigationLink.buttonStyle(.accentWithOutline)
    }
    
    @ViewBuilder
    private var navigationLink: some View {
        if Destination.self == Never.self {
            typedNavigationLink
        } else {
            viewNavigationLink
        }
    }
    
    private var typedNavigationLink: some View {
        typedDestination.map { destination in
            NavigationLink(value: destination) {
                Label(title, systemImage: image)
            }
        }
    }
    
    private var viewNavigationLink: some View {
        viewDestination.map { destination in
            NavigationLink {
                ScrollOffsetReader($scrollOffset) {
                    destination()
                }
                .navigationStackStyleReset(blurOffset: max(abs(min(scrollOffset, 0)), 80))
                
            } label: {
                Label(title, systemImage: image)
            }
        }
    }
}
