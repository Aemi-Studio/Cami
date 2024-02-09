//
//  FAQInformation.swift
//  Cami
//
//  Created by Guillaume Coquard on 09/02/24.
//

import Foundation
import SwiftUI

struct FAQInformation: Hashable, Identifiable {
    let id: UUID = UUID()
    var title: String
    var description: String

    public func search(text: String, exact: Bool = true, anyInsteadOfAll: Bool = true) -> Int {
        if text == "" {
            return 0
        }
        var newText = text.lowercased()
        if title.lowercased().contains(newText) || description.lowercased().contains(newText) {
            return 1
        }
        if exact {
            return -1
        }

        var isInTitle: Bool = true
        var isInDescription: Bool = true
        var isInAnyAtSomePoint = false
        for textPart in text.split(separator: " ") {
            var isInTitleLocal = title.contains(textPart)
            var isInDescriptionLocal = description.contains(textPart)
            isInTitle = isInTitle && isInTitleLocal
            isInDescription = isInDescription && isInDescriptionLocal
            if !isInAnyAtSomePoint {
                isInAnyAtSomePoint = isInTitleLocal || isInDescriptionLocal
            }
        }

        if isInTitle || isInDescription {
            return 2
        }

        if !anyInsteadOfAll {
            return -1
        }

        if isInAnyAtSomePoint {
            return 3
        }

        var newTitle = title
        var newDesc = description
        isInTitle = true
        isInDescription = true
        for char in text {
            if isInTitle, let newTitleIndex = newTitle.firstIndex(of: char) {
                newTitle = String(newTitle[newTitle.index(after: newTitleIndex)...])
            } else {
                isInTitle = false
            }

            if isInDescription, let newDescIndex = newDesc.firstIndex(of: char) {
                newDesc = String(newDesc[newDesc.index(after: newDescIndex)...])
            } else {
                isInDescription = false
            }
            if !(isInTitle || isInDescription) {
                return -1
            }
        }

        return if isInTitle || isInDescription {
            4
        } else {
            -1
        }
    }
}
