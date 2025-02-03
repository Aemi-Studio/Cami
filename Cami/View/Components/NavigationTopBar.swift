//
//  NavigationTopBar.swift
//  Cami
//
//  Created by Guillaume Coquard on 02/02/25.
//

import SwiftUI

struct NavigationTopBar: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.navigation) private var path

    @Namespace private var matchedTitle

    @FocusState private var isFocused: Bool

    @ScaledMetric
    private var topBarInnerHeight = 40.0

    @State
    private var appeared: Bool = false

    init() {
        UITextField.appearance().clearButtonMode = .whileEditing
    }

    private let columns: [GridItem] = [
        .init(.flexible(), alignment: .leading),
        .init(.flexible(), alignment: .center),
        .init(.flexible(), alignment: .trailing)
    ]

    var body: some View {
        if let path {
            VStack(alignment: .center) {
                LazyVGrid(columns: columns) {
                    Color.clear.overlay(alignment: .leading) {
                        backButton
                    }

                    Color.clear.overlay(alignment: .center) {
                        if let current = path.current {
                            Text(current.title)
                                .fontWeight(.medium)
                                .animation(.default, value: current.title)
                                .lineLimit(2)
                                .matchedGeometryEffect(id: current.title, in: matchedTitle)
                        }
                    }

                    Color.clear.overlay(alignment: .trailing) {
                        buttons
                    }
                }
                .frame(height: topBarInnerHeight)
                .frame(maxWidth: .infinity)
                .fixedSize(horizontal: false, vertical: true)

                searchTextField
            }
            .padding()
            .safeAreaPadding(.top, 32)
            .frame(maxWidth: .infinity)
            .background(alignment: .top) {
                if appeared {
                    VariableBlurView(maxBlurRadius: 20, direction: .blurredTopClearBottom)
                    LinearGradient(
                        colors: [Color.background, Color.background.opacity(0)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .animation(.default, value: appeared)
                }
            }
            .fixedSize(horizontal: false, vertical: true)
            .task {
                isFocused = path.isSearchFocused
            }
            .onAppear {
                appeared = true
            }
            .onDisappear {
                appeared = false
            }
            .animation(.default, value: path.isSearchFocused)
            .transition(
                .asymmetric(
                    insertion: .push(from: .top).combined(with: .opacity),
                    removal: .push(from: .bottom).combined(with: .opacity)
                )
            )
            .onAppear {
                dump(path.current?.buttons)
            }
        }
    }

    @ViewBuilder
    private var backButton: some View {
        if let path, !path.isEmpty {
            Button {
                dismissAction()
            } label: {
                if let previous = path.previous() {
                    HStack(spacing: 2) {
                        Image(systemName: "chevron.backward")
                            .font(.headline)
                            .fontWeight(.medium)
                        Text(previous.title)
                            .animation(.default, value: previous)
                            .lineLimit(1)
                            .matchedGeometryEffect(id: previous.title, in: matchedTitle)
                    }
                    .frame(height: topBarInnerHeight)
                }
            }
        } else {
            Spacer()
        }
    }

    @ViewBuilder
    private var buttons: some View {
        if let path, let current = path.current {
            HStack(spacing: 4) {
                AnyView(current.buttons())
                    .labelStyle(.iconOnly)
            }
        }
    }

    @ViewBuilder
    private var searchTextField: some View {
        if let path, let searchable = path.current?.searchable {
            @Bindable var path = path
            if path.isSearchFocused {
                TextField(searchable.prompt, text: searchable.$query)
                    .textFieldStyle(.plain)
                    .focused($isFocused)
                    .onAppear {
                        isFocused = true
                    }
                    .onChange(of: path.isSearchFocused) { _, newValue in
                        if isFocused != newValue {
                            isFocused = newValue
                        }
                    }
                    .onChange(of: isFocused) { _, newValue in
                        if path.isSearchFocused != newValue {
                            path.isSearchFocused = newValue
                        }
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 10)
                    .background(.regularMaterial)
                    .clipShape(.rect(cornerRadius: 8))
                    .overlay {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.clear)
                            .stroke(Color.secondary.tertiary, lineWidth: 0.25)
                    }
                    .frame(height: path.isSearchFocused ? topBarInnerHeight : 0)
                    .transition(
                        .asymmetric(
                            insertion: .push(from: .top).combined(with: .opacity),
                            removal: .push(from: .bottom).combined(with: .opacity)
                        )
                    )
            }
        }
    }

    func dismissAction() {
        path?.pop()
    }
}
