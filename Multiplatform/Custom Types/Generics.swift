//
//  Generics.swift
//  Cami
//
//  Created by Guillaume Coquard on 25/11/23.
//

import Foundation

struct Generic<T: Hashable>: Identifiable, Hashable {

    let id: UUID = UUID()
    let value: T

    init(_ value: T) {
        self.value = value
    }

}
