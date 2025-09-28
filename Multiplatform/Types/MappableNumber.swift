//
//  MappableNumber.swift
//  Cami
//
//  Created by Guillaume Coquard on 30/03/25.
//

import CoreGraphics

protocol MappableNumber {
    func mapped(from rangeA: (Self, Self), to rangeB: (Self, Self)) -> Self
}

extension MappableNumber where Self: FloatingPoint {
    func mapped(from rangeA: (Self, Self), to rangeB: (Self, Self)) -> Self {
        let (minA, maxA) = rangeA
        let (minB, maxB) = rangeB
        guard minA != maxA else {
            return minB
        } // Avoid division by zero

        let scale = (self - minA) / (maxA - minA)
        return minB + scale * (maxB - minB)
    }
}

// Extend Double, Float, and CGFloat
extension Double: MappableNumber {}
extension Float: MappableNumber {}
extension CGFloat: MappableNumber {}
