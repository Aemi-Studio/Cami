//
//  CustomSection.swift
//  Cami
//
//  Created by Guillaume Coquard on 02/02/25.
//

import SwiftUI

struct CustomSection<Header, Content, Footer>: View
where Header: View, Content: View, Footer: View {
    private(set) var header: Header?
    private(set) var content: Content
    private(set) var footer: Footer?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let header {
                header
                    .font(.footnote)
                    .labelStyle(.titleOnly)
                    .foregroundStyle(Color.secondary)
                    .textCase(.uppercase)
                    .padding(.horizontal, 16)
            }
            VStack(alignment: .leading, spacing: 8) {
                content
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            if let footer {
                footer
                    .font(.footnote)
                    .foregroundStyle(Color.secondary)
                    .padding(.horizontal, 16)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    init(
        header: () -> Header?,
        content: () -> Content,
        footer: () -> Footer?
    ) {
        self.header = header()
        self.content = content()
        self.footer = footer()
    }

    init(
        @ViewBuilder content: @escaping () -> Content
    ) where Header == EmptyView, Footer == EmptyView {
        self.content = content()
    }

    init(
        @ViewBuilder header: @escaping () -> Header,
        @ViewBuilder content: @escaping () -> Content
    ) where Footer == AnyView {
        self.header = header()
        self.content = content()
    }

    init(
        @ViewBuilder header: @escaping () -> Header,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder footer: @escaping () -> Footer
    ) {
        self.header = header()
        self.content = content()
        self.footer = footer()
    }
}
