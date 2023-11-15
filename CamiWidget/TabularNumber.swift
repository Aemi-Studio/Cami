//
//  TabularNumber.swift
//  Cami
//
//  Created by Guillaume Coquard on 07/11/23.
//

import SwiftUI

struct TabularNumber: ViewModifier {

    func body(content: Content) -> some View {

        let font = CTFontCreateUIFontForLanguage(.none, 0.0, nil)!

        let fontFeatureSettings: [CFDictionary] = [
            [
                kCTFontFeatureTypeIdentifierKey: kNumberSpacingType,
                kCTFontFeatureSelectorIdentifierKey: kMonospacedNumbersSelector
            ] as CFDictionary
        ]

        let fontDescriptor = CTFontDescriptorCreateWithAttributes([
            kCTFontFeatureSettingsAttribute: fontFeatureSettings
        ] as CFDictionary)

        content
            .font(Font(CTFontCreateCopyWithAttributes(font, 0.0, nil, fontDescriptor)))
    }
}

extension View {

    func tabularNumber() -> some View {
        modifier(TabularNumber())
    }

}
