//
//  ButtonBuilder.swift
//  Cami
//
//  Created by Guillaume Coquard on 03/02/25.
//

import SwiftUI

// swiftlint:disable identifier_name force_cast

@resultBuilder
struct ButtonBuilder {

    private static let paddingVertical: CGFloat = 8
    private static let paddingHorizonal: CGFloat = 16

    private static func standardize(_ view: some View) -> some View {
        Image(systemName: "circle")
            .foregroundStyle(.clear)
            .overlay(alignment: .center) { view }
    }

    static func buildExpression(_ expression: some View) -> some View {
        expression
    }

    static func buildBlock() -> EmptyView {
        EmptyView()
    }

    static func buildBlock(_ content: ConditionalContent<AnyView?>) -> some View {
        content
    }

    static func buildBlock<A>(_ a: A) -> some View where A: View {
        standardize(a)
            .padding(.leading, paddingHorizonal)
            .padding(.vertical, paddingVertical)
            .contentShape(.rect)
    }

    @ViewBuilder
    static func buildBlock<A, B>(_ a: A, _ b: B) -> some View where A: View, B: View {
        Group {
            standardize(a).padding(.horizontal, paddingHorizonal)
            standardize(b).padding(.leading, paddingHorizonal)
        }
        .padding(.vertical, paddingVertical)
    }

    @ViewBuilder
    static func buildBlock<A, B, C>(_ a: A, _ b: B, _ c: C) -> some View where A: View, B: View, C: View {
        Group {
            Group {
                standardize(a)
                standardize(b)
            }
            .padding(.horizontal, paddingHorizonal)
            standardize(c).padding(.leading, paddingHorizonal)
        }
        .padding(.vertical, paddingVertical)
    }

    @ViewBuilder
    static func buildBlock<A, B, C, D>(_ a: A, _ b: B, _ c: C, _ d: D) -> some View
    where A: View, B: View, C: View, D: View {
        Group {
            Group {
                standardize(a)
                standardize(b)
                standardize(c)
            }
            .padding(.horizontal, paddingHorizonal)
            standardize(d).padding(.leading, paddingHorizonal)
        }
        .padding(.vertical, paddingVertical)
    }

    @ViewBuilder
    static func buildBlock<A, B, C, D, E>(_ a: A, _ b: B, _ c: C, _ d: D, _ e: E) -> some View
    where A: View, B: View, C: View, D: View, E: View {
        Group {
            Group {
                standardize(a)
                standardize(b)
                standardize(c)
                standardize(d)
            }
            .padding(.horizontal, paddingHorizonal)
            standardize(e).padding(.leading, paddingHorizonal)
        }
        .padding(.vertical, paddingVertical)
    }

    @ViewBuilder
    static func buildFinalResult<Content: View>(_ component: Content) -> some View {
        component
    }

    static func buildEither<True: View>(first component: True) -> ConditionalContent<AnyView?> {
        conditionalStorage = ConditionalContent(content: component)
        return conditionalStorage
    }

    static func buildEither<False: View>(second component: False) -> ConditionalContent<AnyView?> {
        conditionalStorage = ConditionalContent(content: component)
        return conditionalStorage
    }

    @ViewBuilder
    static func buildOptional<Content: View>(_ component: Content?) -> some View {
        if let component {
            component
        } else {
            EmptyView()
        }
    }

    static var conditionalStorage = ConditionalContent<AnyView?>()

    struct ConditionalContent<Content>: View where Content: View {

        var content: Content

        init() where Content == AnyView? {
            content = nil
        }

        init<Provided>(content: Provided) where Provided: View, Content == AnyView? {
            self.content = AnyView(content)
        }

        var body: some View {
            content
        }
    }

}

// swiftlint:enable identifier_name force_cast
